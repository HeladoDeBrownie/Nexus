local Widget = {}

--# Methods

function Widget:initialize()
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:set_palette(color0, color1, color2, color3)
    self.shader:sendColor('palette',
        color0,
        color1,
        color2,
        color3
    )
end

function Widget:draw(x, y, width, height)
    -- Save all draw state for later reversion.
    love.graphics.push'all'

    love.graphics.setShader(self.shader)

    -- Draw the widget's background.
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.rectangle('fill', x, y, width, height)
    love.graphics.setColor(1, 1, 1)

    -- Run the widget's draw code, which should be overridden for each
    -- specific widget module.
    self:on_draw(x, y, width, height)

    -- Restore the draw state.
    love.graphics.pop()
end

--## Methods to be overridden

function Widget:on_draw(x, y, width, height) end
function Widget:on_key(key, ctrl) end
function Widget:on_scroll(units, ctrl) end
function Widget:on_text_input(text) end

--# Export

return mix{Widget}
