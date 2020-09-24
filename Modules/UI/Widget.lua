local lg = love.graphics

local Widget = {}
local private = setmetatable({}, {__mode = 'k'})
local widget_metatable = {__index = Widget}

function Widget.new()
    local self = setmetatable({}, widget_metatable)

    private[self] = {
        shader = lg.newShader'palette_swap.glsl',
    }

    return self
end

function Widget:set_palette(color0, color1, color2, color3)
    private[self].shader:sendColor('palette',
        color0,
        color1,
        color2,
        color3
    )
end

function Widget:draw(x, y, width, height)
    -- Save all draw state for later reversion.
    lg.push'all'

    lg.setShader(private[self].shader)

    -- Draw the widget's background.
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)

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
