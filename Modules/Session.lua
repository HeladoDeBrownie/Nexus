local Session = {}

--# Requires

local NetworkProtocol = require'NetworkProtocol'
local Socket = require'socket'

--# Constants

local DEFAULT_HOST = 'localhost'

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

local MAXIMUM_PLAYERS = 4

--# Interface

function Session:initialize()
    self:reinitialize()
    self.slot_id = self:connect_slot()
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
                self:connect_slot(new_visitor)

                new_visitor:send(NetworkProtocol.render_message{
                    type = 'welcome',
                    slot_id = slot_id,
                })
            end
        end

        for slot_id = 1, MAXIMUM_PLAYERS do
            local slot = self.slots[slot_id]
            print(slot)

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
        local x, y = self:get_local_player_entity_position()

        if x ~= nil and y ~= nil then
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
