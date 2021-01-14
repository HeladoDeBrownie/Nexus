local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local TextInput = augment(mix{Widget})

-- # Constants

local FONT = require'Font':new(require'Assets/Carpincho Mono')

-- # Interface

function TextInput:initialize()
    Widget.initialize(self)
    self.text_buffer = TextBuffer:new()
    self:bind('Backspace', TextInput.backspace)
end

function TextInput:get_text()
    return self.text_buffer:read()
end

function TextInput:set_text(new_text)
    self.text_buffer:clear()
    self.text_buffer:append(new_text)
end

function TextInput:paint_background()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', 0, 0, self:get_dimensions())
end

function TextInput:paint_foreground()
    FONT:print(self:get_text(), 0, 0)
end

function TextInput:text_input(text)
    self.text_buffer:append(text)
end

function TextInput:backspace()
    self.text_buffer:backspace()
end

-- #

return TextInput
