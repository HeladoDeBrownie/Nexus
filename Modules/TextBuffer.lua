local TextBuffer = {}

--# Requires

local utf8 = require'utf8'

--# Interface

function TextBuffer:initialize()
    self:clear()
end

function TextBuffer:read()
    return self.text
end

function TextBuffer:append(text)
    self.text = self.text .. text
end

function TextBuffer:backspace()
    local text = self.text

    if utf8.len(text) > 0 then
        self.text = text:sub(1, utf8.offset(text, -1) - 1)
    end
end

function TextBuffer:clear()
    self.text = ''
end

return augment(TextBuffer)
