--[[
    Widget is a mixin that handles common drawing behavior and provides defaults
    for common UI methods.
]]

local Widget = {}

--# Methods

function Widget:initialize()
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:set_palette(color0, color1, color2, color3)
    self.shader:sendColor('palette', color0, color1, color2, color3)
end

function Widget:draw(x, y, width, height)
    love.graphics.push'all'
    love.graphics.setShader(self.shader)
    self:draw_background(x, y, width, height)
    self:draw_widget(x, y, width, height)
    love.graphics.pop()
end

function Widget:draw_background(x, y, width, height)
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.rectangle('fill', x, y, width, height)
    love.graphics.setColor(1, 1, 1)
end

-- The remaining methods are explicitly designed to be replaced, but are
-- provided with no-op defaults so that they can reliably be called.

function Widget:draw_widget(x, y, width, height) end
function Widget:on_key(key, down, ctrl) end
function Widget:on_scroll(units, ctrl) end
function Widget:on_text_input(text) end

--# Export

return Widget
