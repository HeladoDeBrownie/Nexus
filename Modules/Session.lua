local Session = {}

--# Requires

local Socket = require'socket'

--# Constants

-- This number spells HELNX, short for “helado Nexus”. It would have been NEXUS
-- (63987), but that would have placed it in the ephemeral ports range.
local DEFAULT_PORT = 43569

local MAXIMUM_PLAYERS = 32

--# Methods

function Session:initialize()
    self.socket = nil
    self.status = 'offline'
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
    self.visitors = {}
    self.status = 'hosting'
end

function Session:join(host, port)
    host = host or 'localhost'
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
            table.insert(self.visitors, new_visitor)
        end

        local random_number = love.math.random(9)

        for _, visitor in ipairs(self.visitors) do
            visitor:send(tostring(random_number) .. '\n')
        end
    elseif self.status == 'visiting' then
        print((self.socket:receive()))
    end
end

return augment(Session)
