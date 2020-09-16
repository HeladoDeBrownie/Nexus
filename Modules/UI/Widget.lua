local Widget = {}
local private = setmetatable({}, {__mode = 'k'})
local widget_metatable = {__index = Widget}
local thread_widget_associations = setmetatable({}, {__mode = 'k'})

function Widget.new()
    return setmetatable({}, widget_metatable)
end

function Widget.get_associated_widget(thread)
    return thread_widget_associations[thread]
end

function Widget:register_associated_thread(thread)
    thread_widget_associations[thread] = self
end

function Widget:on_draw(x, y, width, height)
end

function Widget:on_key(key, ctrl)
end

function Widget:on_scroll(units, ctrl)
end

function Widget:on_text_input(text)
end

function Widget:on_thread_error(error_message, thread)
end

return Widget
