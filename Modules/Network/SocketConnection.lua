-- SocketConnection is an event source that emits messages it receives from its
-- socket in the form of events. It can be used regardless of whether the other
-- end of the socket is a client or a server.

local EventSource = require'EventSource'

local SocketConnection = augment(mix{EventSource})

-- # Helpers

function assert_alive(self)
    assert(self.socket ~= nil, 'connection is dead')
end

-- # Interface

function SocketConnection:initialize(socket)
    EventSource.initialize(self)
    socket:settimeout(0) -- Use the socket in non-blocking mode.
    self.socket = socket
end

function SocketConnection:get_socket()
    return self.socket
end

function SocketConnection:send(message)
    assert_alive(self)
    self.socket:send(message .. '\n')
end

function SocketConnection:process()
    assert_alive(self)

    -- Keep reading messages until there aren't any more queued.
    while true do
        local message, error_reason = self.socket:receive()

        if message ~= nil then
            self:emit('message', message)
        elseif error_reason == 'timeout' then
            break
        elseif error_reason == 'closed' then
            self:disconnect()
            break
        else
            error(error_reason)
        end
    end
end

function SocketConnection:disconnect()
    assert_alive(self)
    self:emit'disconnect'
    self.socket:close()
    self.socket = nil
end

-- #

return SocketConnection
