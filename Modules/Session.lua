local Session = {}

--# Requires

local NetworkProtocol = require'NetworkProtocol'
local Queue = require'Queue'
local Scene = require'Scene'
local Socket = require'socket'
local yield = coroutine.yield

--# Constants

local DEFAULT_HOST = 'localhost'

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

--# Helpers

local function try_coroutine(success, ...)
    if not success then
        error((...))
    else
        return ...
    end
end

local function try_socket(result, error_message)
    if result == nil then
        if error_message ~= 'timeout' then
            error(error_message)
        end
    else
        return result
    end
end

local function co_server_connection(client_socket, message_queue, scene)
    client_socket:settimeout(0)
    local entity_id = scene:add_entity(0, 0)

    message_queue:push{
        type = 'welcome',
        origin = entity_id,
    }

    yield()

    while true do
        local raw_message, error_message = try_socket(client_socket:receive())

        if raw_message ~= nil then
            local message = NetworkProtocol.parse_message(raw_message)

            if message.type == 'place' then
                local x, y = message.x, message.y
                scene:place_entity(entity_id, x, y)
            end
        end

        if not message_queue:is_empty() then
            client_socket:send(NetworkProtocol.render_message(message_queue:pop()) .. '\n')
        end

        yield()
    end
end

local function co_server_accept(server_socket)
    yield()

    while true do
        yield(try_socket(server_socket:accept()))
    end
end

local function co_server(scene, port)
    port = port or DEFAULT_PORT
    local server_socket, error_message = Socket.bind('*', port)

    if server_socket == nil then
        error(error_message)
    else
        server_socket:settimeout(0)
        local clients = {}
        local accept_thread = coroutine.create(co_server_accept)
        try_coroutine(coroutine.resume(accept_thread, server_socket))
        yield()

        while true do
            local client_socket = try_coroutine(coroutine.resume(accept_thread))

            if client_socket ~= nil then
                local client_thread = coroutine.create(co_server_connection)
                local client_queue = Queue:new()
                try_coroutine(coroutine.resume(client_thread, client_socket, client_queue, scene))

                table.insert(clients, {
                    thread = client_thread,
                    queue = client_queue,
                })
            end

            for index, client in ipairs(clients) do
                try_coroutine(coroutine.resume(client.thread))
            end

            yield()
        end
    end
end

local function co_client(scene_view, host, port)
    host = host or DEFAULT_HOST
    port = port or DEFAULT_PORT
    local socket = Socket.connect(host, port)

    if socket == nil then
        error(error_message)
    else
        socket:settimeout(0)
        local scene = Scene:new()
        scene_view:set_scene(scene)
        local entity_id = nil
        local last_x, last_y = nil, nil
        yield()

        while true do
            local raw_message = try_socket(socket:receive())

            if raw_message ~= nil then
                local message = NetworkProtocol.parse_message(raw_message)

                if message.type == 'welcome' then
                    entity_id = message.origin
                    scene:add_entity(0, 0, entity_id)
                    scene_view:set_viewpoint_entity(entity_id)
                    print(entity_id, scene_view:get_viewpoint_entity())
                elseif message.type == 'place' then
                    local x, y = message.x, message.y
                    scene:place_entity(message.origin, x, y)
                end
            end

            if entity_id ~= nil then
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
            end

            yield()
        end
    end
end

_G.co_server = co_server
_G.co_client = co_client

--# Interface

function Session:initialize(scene_view)
    self.thread = nil
    self.status = 'offline'
    self.scene = Scene:new()
    self.scene_view = scene_view
    self.scene_view:set_scene(self.scene)
    self.scene_view:set_viewpoint_entity(self.scene:add_entity(0, 0))
end

function Session:get_scene()
    return self.scene
end

function Session:get_scene_view()
    return self.scene_view
end

function Session:host(port)
    self.thread = coroutine.create(co_server)
    try_coroutine(coroutine.resume(self.thread, self.scene, port))
    self.status = 'hosting'
end

function Session:join(host, port)
    self.thread = coroutine.create(co_client)
    try_coroutine(coroutine.resume(self.thread, self.scene_view, host, port))
    self.status = 'visiting'
end

function Session:disconnect()
    if self.status == 'visiting' then
        self:initialize(self.scene_view)
    else
        self.thread = nil
        self.status = 'offline'
    end
end

function Session:process()
    if self.thread ~= nil then
        if coroutine.status(self.thread) == 'dead' then
            self.thread = nil
        else
            try_coroutine(coroutine.resume(self.thread))
        end
    end
end

return augment(Session)
