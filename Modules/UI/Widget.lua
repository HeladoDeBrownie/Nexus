--[[
    Widget is a mixin that acts as a catch-all for everything that UI elements
    might need to handle. This includes drawing, input, and per-frame logic.
]]

local Bindable = require'UI/Bindable'

local Widget = mix{Bindable}

--# Interface

function Widget:initialize(color_scheme)
    Bindable.initialize(self)
    self.color_scheme = color_scheme
    self.shader = love.graphics.newShader'palette_swap.glsl'
    self.parent = nil
    self.width, self.height = 1, 1
end

function Widget:get_dimensions()
    return self.width, self.height
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
    self.width, self.height = width, height
end

-- Draw the widget to the screen.
function Widget:draw(x, y)
    x, y = x or 0, y or 0
    love.graphics.push'all'
    love.graphics.translate(x, y)
    self:paint()
    love.graphics.pop()
end

function Widget:paint()
    love.graphics.push'all'
    self:apply_palette'background'
    self:paint_background()
    love.graphics.pop()
    love.graphics.push'all'
    self:apply_palette'foreground'
    self:paint_foreground()
    love.graphics.pop()
end

-- Fill the entire widget with the background color.
function Widget:paint_background()
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
function Widget:paint_foreground() end

-- Called when a mouse or touch press occurs.
function Widget:press(x, y) end

-- Called when the mouse wheel scrolls.
function Widget:scroll(units, ctrl) end

-- Called when text is entered.
function Widget:text_input(text) end

-- Called each frame.
function Widget:tick() end

--#

return Widget
