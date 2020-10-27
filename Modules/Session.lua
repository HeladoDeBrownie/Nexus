local Session = {}

--# Requires

local NetworkProtocol = require'NetworkProtocol'
local Socket = require'socket'

--# Constants

local DEFAULT_HOST = 'localhost'

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

local MAXIMUM_PLAYERS = 1

--# Interface

function Session:initialize(scene)
    self.socket = nil
    self.status = 'offline'
    self.scene = scene or require'Scene':new()
    self.player_id = self.scene:add_entity(0, 0)
    self.slots = {}
end

function Session:get_scene()
    return self.scene
end

function Session:get_player_id()
    return self.player_id
end

-- For debug purposes only. This method will likely be removed.
function Session:get_socket()
    return self.socket
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
    self.socket = socket
    self.status = 'visiting'
end

function Session:disconnect()
    self.socket = nil
    self.status = 'offline'
end

function Session:process()
    if self.status == 'hosting' then
        local new_visitor = self.socket:accept()

        if new_visitor ~= nil then
            local slot_id = self:allocate_slot_id()

            if slot_id ~= nil then
                new_visitor:settimeout(0)
                self.slots[slot_id] = new_visitor

                new_visitor:send(NetworkProtocol.render_message{
                    type = 'welcome',
                    slot_id = slot_id,
                })
            end
        end

        for slot_id = 1, MAXIMUM_PLAYERS do
            local visitor = self.slots[slot_id]

            if visitor ~= nil then
                local raw_message, error_message = visitor:receive()

                if raw_message == nil then
                    if error_message == 'closed' then
                        self.slots[slot_id] = nil
                    end
                else
                    local message = NetworkProtocol.parse_message(raw_message)

                    if message.type == 'place' then
                        self.scene:place_entity(
                            self.player_id,
                            message.x,
                            message.y
                        )
                    end
                end
            end
        end
    elseif self.status == 'visiting' then
        local x, y = self.scene:get_entity_position(self.player_id)

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

function Session:allocate_slot_id()
    for slot_id = 1, MAXIMUM_PLAYERS do
        if self.slots[slot_id] == nil then
            return slot_id
        end
    end
end

return augment(Session)
