local Widget = require'UI/Widget'

local Button = augment(mix{Widget})

-- # Constants

local DEFAULT_LABEL = 'Button'
local FONT = require'Font':new(require'Assets/Carpincho Mono')

-- # Interface

function Button:initialize(label, action)
    Widget.initialize(self)
    self:set_label(label)
    self:set_action(action)
end

function Button:get_label()
    return self.label or DEFAULT_LABEL
end

function Button:set_label(new_label)
    self.label = new_label
end

function Button:set_action(new_action)
    self.action = new_action
end

function Button:press(...)
    if self.action ~= nil then
        self.action()
    end
end

function Button:paint_background()
    love.graphics.rectangle('fill', 0, 0, self:get_dimensions())
end

function Button:paint_foreground()
    FONT:print(self:get_label(), 0, 0)
end

-- #

return Button
