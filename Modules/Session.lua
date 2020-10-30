local Session = {}

--# Requires

local NetworkProtocol = require'NetworkProtocol'
local Scene = require'Scene'
local Socket = require'socket'
local yield = coroutine.yield

--# Constants

local DEFAULT_HOST = 'localhost'

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

local MAXIMUM_PLAYERS = 4

--# Helpers

local function co_server_connection(client_socket, scene)
    local entity_id = scene:add_entity(0, 0)
    yield()

    while true do
        local raw_message, error_message = client_socket:receive()

        if raw_message == nil then
            if error_message ~= 'timeout' then
                scene:remove_entity(entity_id)
                error(error_message)
            end
        else
            local message = NetworkProtocol.parse_message(raw_message)

            if message.type == 'place' then
                local x, y = message.x, message.y
                scene:place_entity(entity_id, x, y)
            end
        end

        yield()
    end
end

local function co_server_accept(server_socket, threads, scene)
    yield()

    while true do
        local client_socket, error_message = server_socket:accept()

        if client_socket == nil then
            if error_message ~= 'timeout' then
                error(error_message)
            end
        else
            client_socket:settimeout(0)
            local connection_thread = coroutine.create(co_server_connection)
            coroutine.resume(connection_thread, client_socket, scene)
            table.insert(threads, connection_thread)
        end

        yield()
    end
end

local function co_server(port, scene)
    local server_socket, error_message = Socket.bind('*', port)

    if server_socket == nil then
        error(error_message)
    else
        server_socket:settimeout(0)
        local threads = {}
        local accept_thread = coroutine.create(co_server_accept)
        coroutine.resume(accept_thread, server_socket, threads, scene)
        table.insert(threads, accept_thread)
        yield()

        while true do
            for index, thread in ipairs(threads) do
                local success, error_message = coroutine.resume(thread)

                if not success then
                    table.remove(threads, index)
                    print(error_message)
                end
            end

            yield()
        end
    end
end

local function co_client(host, port, scene_view)
    local socket = Socket.connect(host, port)

    if socket == nil then
        error(error_message)
    else
        socket:settimeout(0)
        local scene = Scene:new()
        local entity_id = scene:add_entity(0, 0)
        scene_view:set_scene(scene)
        scene_view:set_viewpoint_entity(entity_id)
        local last_x, last_y = nil, nil
        yield()

        while true do
            local x, y = scene:get_entity_position(entity_id)

            if x ~= last_x or y ~= last_y then
                local result, error_message = socket:send(
                    NetworkProtocol.render_message{
                        type = 'place',
                        x = x,
                        y = y,
                    }
                .. '\n')

                if result == nil then
                    if error_message == 'closed' then
                        break
                    end
                end
            end

            yield()
        end
    end
end

_G.co_server = co_server
_G.co_client = co_client

--# Interface

function Session:initialize(scene_view)
    self:reinitialize()
    self.scene_view = scene_view
    self.scene_view:set_scene(self.scene)
    self.slot_id = self:connect_slot()
    self.scene_view:set_viewpoint_entity(self.slots[self.slot_id].entity_id)
end

function Session:reinitialize()
    self.socket = nil
    self.status = 'offline'
    self.scene = require'Scene':new()
    self.slots = {}
end

function Session:get_scene()
    return self.scene
end

function Session:get_scene_view()
    return self.scene_view
end

function Session:get_slot_id()
    return self.slot_id
end

function Session:get_entity_id(slot_id)
    local slot = self.slots[slot_id]

    if slot ~= nil then
        return slot.entity_id
    end
end

function Session:is_online()
    return self.status == 'hosting' or self.status == 'visiting'
end

function Session:is_hosting()
    return self.status == 'hosting'
end

function Session:host(port)
    port = port or DEFAULT_PORT
    local socket = Socket.bind('*', port)
    socket:settimeout(0)
    self.socket = socket
    self.status = 'hosting'
end

function Session:join(host, port)
    host = host or DEFAULT_HOST
    port = port or DEFAULT_PORT
    local socket = Socket.connect(host, port)
    socket:settimeout(0)
    --self:initialize()
    self.socket = socket
    self.status = 'visiting'
end

function Session:disconnect()
    if self.status == 'visiting' then
        self:initialize()
    else
        self.socket = nil
        self.status = 'offline'
    end
end

function Session:process()
    if self.status == 'hosting' then
        local new_visitor = self.socket:accept()

        if new_visitor ~= nil then
            local slot_id = self:connect_slot(new_visitor)

            if slot_id ~= nil then
                new_visitor:settimeout(0)

                new_visitor:send(NetworkProtocol.render_message{
                    type = 'welcome',
                    slot_id = slot_id,
                })
            end
        end

        for slot_id = 1, MAXIMUM_PLAYERS do
            local slot = self.slots[slot_id]

            if slot ~= nil and slot.socket ~= nil then
                local raw_message, error_message = slot.socket:receive()

                if raw_message == nil then
                    if error_message == 'closed' then
                        self.slots[slot_id] = nil
                    end
                else
                    local message = NetworkProtocol.parse_message(raw_message)

                    if message.type == 'place' then
                        self.scene:place_entity(
                            slot.entity_id,
                            message.x,
                            message.y
                        )
                    end
                end
            end
        end
    elseif self.status == 'visiting' then
        local slot = self.slots[self:get_slot_id()]
        local last_x, last_y = slot.last_x, slot.last_y
        local x, y = self:get_local_player_entity_position()

        if x ~= nil and y ~= nil and last_x ~= x or last_y ~= y then
            slot.last_x, slot.last_y = x, y

            local result, error_message = self.socket:send(NetworkProtocol.render_message{
                type = 'place',
                x = x,
                y = y,
            } .. '\n')

            if result == nil then
                if error_message == 'closed' then
                    self:disconnect()
                end
            end
        end
    end
end

function Session:connect_slot(socket)
    local slot_id = self:allocate_slot_id()

    if slot_id ~= nil then
        local entity_id = self.scene:add_entity(0, 0)

        if entity_id ~= nil then
            self.slots[slot_id] = {
                entity_id = entity_id,
                socket = socket,
            }
        end
    end

    return slot_id
end

function Session:allocate_slot_id()
    for slot_id = 1, MAXIMUM_PLAYERS do
        if self.slots[slot_id] == nil then
            return slot_id
        end
    end
end

function Session:get_local_player_entity_id()
    return self:get_entity_id(self:get_slot_id())
end

function Session:get_local_player_entity_position()
    local x, y = self.scene:get_entity_position(self:get_local_player_entity_id())

    if x == nil or y == nil then
        return 0, 0
    else
        return x, y
    end
end

return augment(Session)
