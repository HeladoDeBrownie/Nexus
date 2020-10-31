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

local function co_server_connection(client_socket, output_queue, session_queue, scene)
    client_socket:settimeout(0)
    local entity_id = scene:add_entity(0, 0)

    output_queue:push{
        type = 'welcome',
        origin = entity_id,
    }

    yield(entity_id)

    while true do
        local raw_message, error_message = try_socket(client_socket:receive())

        if raw_message ~= nil then
            local message = NetworkProtocol.parse_message(raw_message)
            message.origin = entity_id
            session_queue:push(message)
        end

        if not output_queue:is_empty() then
            client_socket:send(NetworkProtocol.render_message(output_queue:pop()) .. '\n')
        end

        yield()
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
        local session_queue = Queue:new()
        yield()

        while true do
            local client_socket = try_socket(server_socket:accept())

            if client_socket ~= nil then
                local client_thread = coroutine.create(co_server_connection)
                local client_queue = Queue:new()

                for _, client in ipairs(clients) do
                    local x, y = scene:get_entity_position(client.origin)

                    client_queue:push{
                        type = 'place',
                        x = x,
                        y = y,
                        origin = client.origin,
                    }
                end

                local origin = try_coroutine(coroutine.resume(client_thread, client_socket, client_queue, session_queue, scene))

                table.insert(clients, {
                    thread = client_thread,
                    queue = client_queue,
                    origin = origin,
                })
            end

            for index, client in ipairs(clients) do
                try_coroutine(coroutine.resume(client.thread))
            end

            while not session_queue:is_empty() do
                local message = session_queue:pop()

                if message.type == 'place' then
                    local origin, x, y = message.origin, message.x, message.y
                    scene:place_entity(origin, x, y)

                    for _, client in ipairs(clients) do
                        if origin ~= client.origin then
                            client.queue:push{
                                type = 'place',
                                x = x,
                                y = y,
                                origin = origin,
                            }
                        end
                    end
                end
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
                elseif message.type == 'place' then
                    local x, y = message.x, message.y
                    scene:place_entity(message.origin, x, y)
                end
            end

            if entity_id ~= nil then
                local x, y = scene:get_entity_position(entity_id)

                if x ~= last_x or y ~= last_y then
                    try_socket(socket:send(
                        NetworkProtocol.render_message{
                            type = 'place',
                            x = x,
                            y = y,
                        }
                    .. '\n'))
                end

                last_x, last_y = x, y
            end

            yield()
        end
    end
end

--# Interface

function Session:initialize(scene_view)
    self.host_thread = nil
    self.visitor_thread = nil
    self.status = 'offline'
    self.scene = Scene:new()
    self.scene_view = scene_view
    self.scene_view:set_scene(self.scene)
    --self.scene_view:set_viewpoint_entity(self.scene:add_entity(0, 0))
end

function Session:get_scene()
    return self.scene
end

function Session:get_scene_view()
    return self.scene_view
end

function Session:host(port)
    self.host_thread = coroutine.create(co_server)
    try_coroutine(coroutine.resume(self.host_thread, self.scene, port))
    self.status = 'hosting'
    self:join('localhost', port)
end

function Session:join(host, port)
    self.visitor_thread = coroutine.create(co_client)
    try_coroutine(coroutine.resume(self.visitor_thread, self.scene_view, host, port))
    self.status = 'visiting'
end

function Session:disconnect()
    if self.status == 'visiting' then
        self:initialize(self.scene_view)
    else
        self.host_thread = nil
        self.visitor_thread = nil
        self.status = 'offline'
    end
end

function Session:process()
    if self.host_thread ~= nil then
        if coroutine.status(self.host_thread) == 'dead' then
            self:disconnect()
        else
            try_coroutine(coroutine.resume(self.host_thread))
        end
    end

    if self.visitor_thread ~= nil then
        if coroutine.status(self.visitor_thread) == 'dead' then
            self:disconnect()
        else
            try_coroutine(coroutine.resume(self.visitor_thread))
        end
    end
end

return augment(Session)
