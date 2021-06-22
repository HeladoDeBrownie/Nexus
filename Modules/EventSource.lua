local EventSource = augment{}

-- # Interface

function EventSource:initialize()
    self.event_name_to_listeners = {}
end

function EventSource:emit(event_name, ...)
    assert(event_name ~= nil, 'event name must not be nil')
    local listeners = self.event_name_to_listeners[event_name]

    if listeners ~= nil then
        for index, listener in ipairs(listeners) do
            listener.handler(self, event_name, ...)
        end
    end
end

function EventSource:listen(event_name, handler, tag)
    assert(event_name ~= nil, 'event name must not be nil')
    assert(handler ~= nil, 'handler must not be nil')
    local listeners = self.event_name_to_listeners[event_name]

    local listener = {
        handler = handler,
        tag = tag,
    }

    if listeners == nil then
        self.event_name_to_listeners[event_name] = {listener}
    else
        table.insert(listeners, listener)
    end
end

function EventSource:unlisten(event_name, handler)
    assert(event_name ~= nil, 'event name must not be nil')
    assert(handler ~= nil, 'handler must not be nil')
    local listeners = self.event_name_to_listeners[event_name]

    if listeners ~= nil then
        for index, listener in ipairs(listeners) do
            if listener.handler == handler then
                table.remove(listeners, index)
                break
            end
        end

        if listeners[1] == nil then
            self.event_name_to_listeners[event_name] = nil
        end
    end
end

function EventSource:unlisten_by_tag(tag)
    assert(tag ~= nil, 'tag must not be nil')

    for event_name, listeners in pairs(self.event_name_to_listeners) do
        for index, listener in ipairs(listeners) do
            if listener.tag == tag then
                table.remove(listeners, index)
            end
        end

        if listeners[1] == nil then
            self.event_name_to_listeners[event_name] = nil
        end
    end
end

-- #

return EventSource
