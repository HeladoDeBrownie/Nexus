local Session = {}

--# Requires

local socket = require'socket'

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
    self.socket = socket.bind('*', port)
    self.status = 'hosting'
end

function Session:join(host, port)
    port = port or DEFAULT_PORT
    self.socket = socket.connect(host, port)
    self.status = 'visiting'
end

function Session:disconnect()
    self.socket = nil
    self.status = 'offline'
end

function Session:process() end

return augment(Session)
