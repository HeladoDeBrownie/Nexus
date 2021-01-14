local Widget = require'UI/Widget'

local Label = augment(mix{Widget})

-- # Constants

local FONT = require'Font':new(require'Assets/Carpincho Mono')

-- # Interface

function Label:initialize(text)
    Widget.initialize(self)
    self.text = text
end

function Label:get_text()
    return self.text
end

function Label:set_text(new_text)
    self.text = new_text
end

function Label:paint_foreground()
    FONT:print(self.text)
end

return Label
