local Session = {}

--# Requires

local Socket = require'socket'

--# Constants

local DEFAULT_HOST = 'localhost'

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

local MAXIMUM_PLAYERS = 32

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
                self.slots[slot_id] = new_visitor
            end
        end

        local random_number = love.math.random(9)

        for slot_id = 1, MAXIMUM_PLAYERS do
            local visitor = self.slots[slot_id]

            if visitor ~= nil then
                visitor:send(tostring(random_number) .. '\n')
            end
        end

    elseif self.status == 'visiting' then
        print((self.socket:receive()))
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
