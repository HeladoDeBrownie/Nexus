local Session = {}

--# Requires

local Protocol = require'Network/Protocol'
local Queue = require'Queue'
local Scene = require'Scene'
local SessionCache = require'SessionCache'
local Socket = require'socket'
local Sprite = require'Sprite'
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

local function send_to_all_but(excepted_origin, clients, message)
    for origin, client in pairs(clients) do
        if origin ~= excepted_origin then
            client.queue:push(message)
        end
    end
end

local function co_server_connection(client_socket, output_queue, session_queue, scene)
    client_socket:settimeout(0)
    local entity_id = scene:allocate_entity_id()
    yield(entity_id)

    while true do
        repeat
            local raw_message = try_socket(client_socket:receive())

            if raw_message ~= nil then
                local message = Protocol.parse_message(raw_message)
                message.origin = entity_id
                session_queue:push(message)
            end
        until raw_message == nil

        while not output_queue:is_empty() do
            client_socket:send(Protocol.render_message(output_queue:pop()) .. '\n')
        end

        yield()
    end
end

local function co_server(session, port)
    port = port or DEFAULT_PORT
    local server_socket = try_socket(Socket.bind('*', port))
    server_socket:settimeout(0)
    local clients = {}
    yield()

    while true do
        local client_socket = try_socket(server_socket:accept())

        if client_socket ~= nil then
            local client_thread = coroutine.create(co_server_connection)
            local client_queue = Queue:new()

            client_queue:push{
                type = 'scene',
                data = session.scene:serialize(),
            }

            local origin = try_coroutine(coroutine.resume(client_thread, client_socket, client_queue, session.message_queue, session.scene))

            clients[origin] = {
                thread = client_thread,
                queue = client_queue,
                origin = origin,
            }
        end

        for index, client in pairs(clients) do
            try_coroutine(coroutine.resume(client.thread))
        end

        while not session.message_queue:is_empty() do
            local message = session.message_queue:pop()
            local origin = message.origin

            if message.type == 'hello' then
                local sprite_byte_string = message.sprite_byte_string
                session.scene:add_entity(origin, Sprite.from_byte_string(sprite_byte_string), 0, 0)

                clients[origin].queue:push{
                    type = 'welcome',
                    origin = origin,
                }

                send_to_all_but(nil, clients, {
                    type = 'scene',
                    data = session.scene:serialize()
                })
            elseif message.type == 'place' then
                local x, y = message.x, message.y
                session.scene:place_entity(origin, x, y)
                send_to_all_but(origin, clients, message)
            elseif message.type == 'sprite' then
                session.scene:set_entity_sprite(origin, Sprite.from_byte_string(message.sprite_byte_string))
                send_to_all_but(origin, clients, message)
            end
        end

        yield()
    end
end

local function co_client(scene_view, host, port, message_queue)
    host = host or DEFAULT_HOST
    port = port or DEFAULT_PORT
    local socket = try_socket(Socket.connect(host, port))
    socket:settimeout(0)
    local scene = Scene:new()
    scene_view:set_scene(scene)
    local entity_id = nil
    local sprite = SessionCache.player_sprite
    yield()

    try_socket(socket:send(Protocol.render_message{
        type = 'hello',
        sprite_byte_string = sprite:to_byte_string(),
    } .. '\n'))

    while true do
        while not message_queue:is_empty() do
            local raw_message = Protocol.render_message(message_queue:pop())
            try_socket(socket:send(raw_message .. '\n'))
        end

        repeat
            local raw_message = try_socket(socket:receive())

            if raw_message ~= nil then
                local message = Protocol.parse_message(raw_message)

                if message.type == 'welcome' then
                    entity_id = message.origin
                    scene:add_entity(entity_id, sprite, 0, 0)
                    scene_view:set_viewpoint_entity(entity_id)
                elseif message.type == 'place' then
                    local x, y = message.x, message.y
                    scene:place_entity(message.origin, x, y)
                elseif message.type == 'scene' then
                    local data = message.data

                    if entity_id ~= nil then
                        local x, y = scene:get_entity_position(entity_id)
                        scene:deserialize(data)
                        scene:place_entity(entity_id, x, y)
                    else
                        scene:deserialize(data)
                    end
                elseif message.type == 'sprite' then
                    scene:set_entity_sprite(message.origin, Sprite.from_byte_string(message.sprite_byte_string))
                end
            end
        until raw_message == nil

        yield()
    end
end

--# Interface

function Session:initialize(scene_view)
    self.thread = nil
    self.status = 'offline'
    self.scene = Scene:new()
    self.scene_view = scene_view
    self.scene_view:set_session(self._public)
    self.scene_view:set_scene(self.scene)
    self.scene_view:set_viewpoint_entity(self.scene:add_entity(nil, SessionCache.player_sprite, 0, 0))
    self.message_queue = nil
end

function Session:get_scene()
    return self.scene
end

function Session:get_scene_view()
    return self.scene_view
end

function Session:host(port)
    self.thread = coroutine.create(co_server)
    self.message_queue = Queue:new()
    try_coroutine(coroutine.resume(self.thread, self, port))
    self.status = 'hosting'
end

function Session:join(host, port)
    self.thread = coroutine.create(co_client)
    self.message_queue = Queue:new()
    try_coroutine(coroutine.resume(self.thread, self.scene_view, host, port, self.message_queue))
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
            self:disconnect()
        else
            try_coroutine(coroutine.resume(self.thread))
        end
    end
end

function Session:broadcast_message(message)
    if self.message_queue ~= nil then
        self.message_queue:push(message)
    end
end

return augment(Session)
