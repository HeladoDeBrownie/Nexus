--[[
    Widget is a mixin that handles common drawing behavior and provides defaults
    for common UI methods.
]]

local Widget = {}

--# Requires

local utf8 = require'utf8'
local is_ctrl_down = require'Helpers'.is_ctrl_down

--# Interface

function Widget:initialize()
    self.widget_canvas = love.graphics.newCanvas()
    self.bindings = {}
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:get_canvas()
    return self.widget_canvas
end

function Widget:get_dimensions()
    return self.widget_canvas:getDimensions()
end

function Widget:on_key(key, down)
    if down then
        local key_combination =
            key:gsub(utf8.charpattern, string.upper, 1)

        if is_ctrl_down() then
            key_combination = 'Ctrl+' .. key_combination
        end

        local binding = self.bindings[key_combination]

        if binding == nil then
            return self:on_unbound_key(key, down)
        else
            return binding.handler(self, binding.extra_data)
        end
    else
        return self:on_unbound_key(key, down)
    end
end

function Widget:bind(key_combination, handler, extra_data)
    self.bindings[key_combination] = {
        handler = handler,
        extra_data = extra_data,
    }
end

function Widget:set_palette(color0, color1, color2, color3)
    self.shader:sendColor('palette', color0, color1, color2, color3)
end

function Widget:draw()
    love.graphics.push'all'
    love.graphics.setCanvas(self.widget_canvas)
    love.graphics.setShader(self.shader)
    self:draw_background()
    self:draw_widget()
    love.graphics.pop()
end

function Widget:resize(width, height)
    self.widget_canvas = love.graphics.newCanvas(width, height)
    self:draw()
end

function Widget:draw_background()
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, self:get_dimensions())
    love.graphics.setColor(1, 1, 1)
end

-- The remaining methods are explicitly designed to be replaced, but are
-- provided with no-op defaults so that they can reliably be called.

function Widget:draw_widget() end
function Widget:on_press(x, y) end
function Widget:on_scroll(units, ctrl) end
function Widget:on_text_input(text) end
function Widget:on_unbound_key(key, down) end
function Widget:tick() end

return Widget
