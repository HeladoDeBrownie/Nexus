local EventSource = augment{}

-- # Interface

function EventSource:initialize()
    self.event_name_to_listeners = {}
end

function EventSource:emit(event_name, ...)
    local handlers = self.event_name_to_listeners[event_name]

    if handlers ~= nil then
        for index, handler in ipairs(handlers) do
            handler(event_name, ...)
        end
    end
end

function EventSource:listen(event_name, handler)
    local handlers = self.event_name_to_listeners[event_name]

    if handlers == nil then
        self.event_name_to_listeners[event_name] = {handler}
    else
        table.insert(handlers, handler)
    end
end

function EventSource:unlisten(event_name, handler)
    local handlers = self.event_name_to_listeners[event_name]

    if handlers ~= nil then
        for index, current_handler in ipairs(handlers) do
            if current_handler == handler then
                table.remove(handlers, index)
                break
            end
        end

        if handlers[1] == nil then
            self.event_name_to_listeners[event_name] = nil
        end
    end
end

-- #

return EventSource
