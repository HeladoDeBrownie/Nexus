local lg = love.graphics

local UISettings = require'Settings'.UI
local Widget = {}
local private = setmetatable({}, {__mode = 'k'})
local widget_metatable = {__index = Widget}

function Widget.new()
    return setmetatable({}, widget_metatable)
end

function Widget:draw(x, y, width, height)
    -- Save all draw state for later reversion.
    lg.push'all'

    -- Draw the widget's background.
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)

    -- Apply the global scale factor.
    lg.scale(UISettings.global_scale)

    -- Run the widget's draw code, which should be overridden for each specific
    -- widget module.
    self:on_draw(x, y, width, height)

    -- Restore the draw state.
    lg.pop()
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
