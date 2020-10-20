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
    self.status = 'offline'
end

function Session:is_online()
    return self.status == 'hosting' or self.status == 'visiting'
end

function Session:is_hosting()
    return self.status == 'hosting'
end

function Session:host(port)
    port = port or DEFAULT_PORT
    error'TODO'
end

function Session:join(host, port)
    port = port or DEFAULT_PORT
    error'TODO'
end

function Session:disconnect() end

function Session:process() end

return augment(Session)
