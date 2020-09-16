local Widget = {}
local private = setmetatable({}, {__mode = 'k'})
local widget_metatable = {__index = Widget}
local thread_widget_associations = setmetatable({}, {__mode = 'k'})

function Widget.new()
    return setmetatable({}, widget_metatable)
end

function Widget:on_draw(x, y, width, height)
end

function Widget:on_key(key, ctrl)
end

function Widget:on_scroll(units, ctrl)
end

function Widget:on_text_input(text)
end

return Widget
