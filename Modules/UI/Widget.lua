--[[
    Widget is a mixin that handles common drawing behavior and provides defaults
    for common UI methods.
]]

local Widget = {}

--# Requires

local utf8 = require'utf8'

--# Interface

function Widget:initialize()
    self.bindings = {}
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:on_key(key, down, ctrl)
    if down then
        local key_combination =
            key:gsub(utf8.charpattern, string.upper, 1)

        if ctrl then
            key_combination = 'Ctrl+' .. key_combination
        end

        local binding = self.bindings[key_combination]

        if binding ~= nil then
            return binding(self)
        end
    end
end

function Widget:bind(key_combination, handler)
    self.bindings[key_combination] = handler
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
function Widget:on_scroll(units, ctrl) end
function Widget:on_text_input(text) end
function Widget:tick() end

return Widget
