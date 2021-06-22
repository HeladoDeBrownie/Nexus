local EventSource = require'EventSource'

local Host = augment(mix{EventSource})

-- # Interface

function Host:initialize(area)
    EventSource.initialize(self)
    self.area = area
    self.connections = {}
end

function Host:each_connection()
    local index = 0

    return function ()
        index = index + 1
        return self.connections[index]
    end
end

function Host:connect(connection)
    table.insert(self.connections, connection)
    connection:send'HELLO'

    connection:listen('message', function (_, _, message)
        print('message:', message)
    end, self._public)

    connection:listen('disconnect', function ()
        print'disconnect'
        self:disconnect(connection)
    end, self._public)
end

function Host:disconnect(connection)
    for index, current_connection in ipairs(self.connections) do
        if current_connection == connection then
            connection:unlisten_by_tag(self._public)
            table.remove(self.connections, index)
            break
        end
    end
end

function Host:process()
    for connection in self:each_connection() do
        connection:process()
    end
end

-- #

return Host
