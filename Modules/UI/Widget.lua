local lg = love.graphics

local Widget = {}
local private = setmetatable({}, {__mode = 'k'})
local widget_metatable = {__index = Widget}

function Widget.new()
    return setmetatable({}, widget_metatable)
end

function Widget:draw_background(x, y, width, height)
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)
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
