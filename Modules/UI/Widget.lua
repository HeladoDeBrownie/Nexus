--[[
    Widget is a mixin that acts as a catch-all for everything that UI elements
    might need to handle. This includes drawing, input, and per-frame logic.
]]

local Widget = {}

--# Requires

local utf8 = require'utf8'
local is_ctrl_down = require'Helpers'.is_ctrl_down

--# Helpers

local function key_combination_string(key, ctrl_down)
    local result = key:gsub(utf8.charpattern, string.upper, 1)

    if ctrl_down then
        result = 'Ctrl+' .. result
    end

    return result
end

--# Interface

function Widget:initialize()
    self.bindings = {}
    self.canvas = love.graphics.newCanvas()
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:get_canvas()
    return self.canvas
end

function Widget:get_dimensions()
    return self.canvas:getDimensions()
end

function Widget:resize(width, height)
    -- Canvas dimensions cannot be changed after they're created, so instead
    -- discard the old canvas and create a new one of the correct size.
    self.canvas = love.graphics.newCanvas(width, height)
end

function Widget:set_palette(color0, color1, color2, color3)
    self.shader:sendColor('palette', color0, color1, color2, color3)
end

--## Input

-- Create a key binding, used by Widget.on_key to handle key combinations.
function Widget:bind(key_combination, handler, extra_data)
    self.bindings[key_combination] = {
        handler = handler,
        extra_data = extra_data,
    }
end

function Widget:on_key(key, down)
    -- When a key combination is pressed, trigger a binding if there is an
    -- appropriate one. Otherwise, call the fallback key handler.
    if down then
        local key_combination = key_combination_string(key, is_ctrl_down())
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

--## Drawing

-- Draw the widget to its canvas. This does *not* draw it to the screen. For
-- screen drawing, use love.graphics.draw with Widget.get_canvas.
function Widget:draw()
    love.graphics.push'all'
    love.graphics.setCanvas(self.canvas)
    love.graphics.setShader(self.shader)
    self:draw_background()
    self:draw_widget()
    love.graphics.pop()
end

-- Fill the entire widget with the background color.
function Widget:draw_background()
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.rectangle('fill', 0, 0, self:get_dimensions())
    love.graphics.setColor(1, 1, 1)
end

--## Abstract

--[[
    The remaining methods are explicitly designed to be replaced, but are
    provided with no-op defaults so that they can reliably be called and simply
    ignored if not applicable.
--]]

-- Called by Widget.draw after setting up the draw state.
function Widget:draw_widget() end

-- Called when a mouse or touch press occurs.
function Widget:on_press(x, y) end

-- Called when the mouse wheel scrolls.
function Widget:on_scroll(units, ctrl) end

-- Called when text is entered.
function Widget:on_text_input(text) end

-- Called when a key combination is not handled by a binding.
function Widget:on_unbound_key(key, down) end

-- Called each frame.
function Widget:tick() end

--#

return Widget
