local Area = require'Area'
local EventSource = require'EventSource'

local Visitor = augment(mix{EventSource})

-- # Interface

function Visitor:initialize(connection)
    EventSource.initialize(self)
    self.connection = connection
    self.area = Area:new()

    connection:listen('message', function (_, _, message)
        print('message:', message)

        if message == 'HELLO' then
            connection:send'HELLOTOO'
        end
    end, self._public)

    connection:listen('disconnect', function ()
        print'disconnect'
        self:disconnect()
    end, self._public)
end

function Visitor:process()
    if self.connection ~= nil then
        self.connection:process()
    end
end

function Visitor:disconnect()
    self.connection:unlisten_by_tag(self._public)
    self.connection = nil
end

-- #

return Visitor
