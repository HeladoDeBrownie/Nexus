--[[
    Widget is a mixin that acts as a catch-all for everything that UI elements
    might need to handle. This includes drawing, input, and per-frame logic.
]]

local Bindable = require'UI/Bindable'

local Widget = mix{Bindable}

--# Interface

function Widget:initialize(color_scheme)
    Bindable.initialize(self)
    self.canvas = love.graphics.newCanvas()
    self.color_scheme = color_scheme
    self.shader = love.graphics.newShader'palette_swap.glsl'
    self.parent = nil
end

function Widget:get_canvas()
    return self.canvas
end

function Widget:get_dimensions()
    return self.canvas:getDimensions()
end

function Widget:get_parent()
    return self.parent
end

function Widget:set_parent(new_parent)
    self.parent = new_parent
end

function Widget:apply_palette(background_or_foreground)
    if self.color_scheme ~= nil then
        love.graphics.setShader(self.shader)

        self.shader:sendColor('palette',
            self.color_scheme:to_normalized_rgba(background_or_foreground)
        )
    elseif self.parent ~= nil then
        self.parent:apply_palette(background_or_foreground)
    end
end

function Widget:resize(width, height)
    -- Canvas dimensions cannot be changed after they're created, so instead
    -- discard the old canvas and create a new one of the correct size.
    self.canvas = love.graphics.newCanvas(width, height)
end

-- Draw the widget to its canvas. This does *not* draw it to the screen. For
-- screen drawing, use love.graphics.draw with Widget.get_canvas.
function Widget:draw()
    love.graphics.push'all'
    self:before_drawing()
    love.graphics.push'all'
    self:apply_palette'background'
    self:draw_background()
    love.graphics.pop()
    love.graphics.push'all'
    self:apply_palette'foreground'
    self:draw_foreground()
    love.graphics.pop()
    love.graphics.pop()
end

function Widget:before_drawing()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
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
function Widget:draw_foreground() end

-- Called when a mouse or touch press occurs.
function Widget:on_press(x, y) end

-- Called when the mouse wheel scrolls.
function Widget:on_scroll(units, ctrl) end

-- Called when text is entered.
function Widget:on_text_input(text) end

-- Called each frame.
function Widget:tick() end

--#

return Widget
