local TextBuffer = {}

--# Requires

local utf8 = require'utf8'

--# Interface

function TextBuffer:initialize()
    self:clear()
end

function TextBuffer:read()
    local joined_text = ''

    for line_number, line in ipairs(self.lines) do
        if line_number > 1 then
            joined_text = joined_text .. '\n'
        end

        joined_text = joined_text .. line
    end

    return joined_text
end

function TextBuffer:append(text)
    for line in (text .. '\n'):gmatch'([^\n]*)\n' do
        self.lines[self.last_line_number] =
            self.lines[self.last_line_number] .. line

        self.last_line_number = self.last_line_number + 1
        self.lines[self.last_line_number] = ''
    end

    self:backspace()
end

function TextBuffer:backspace()
    local line = self.lines[self.last_line_number]

    if utf8.len(line) > 0 then
        self.lines[self.last_line_number] = line:sub(1, utf8.offset(line, -1) - 1)
    elseif self.last_line_number > 1 then
        self.lines[self.last_line_number] = nil
        self.last_line_number = self.last_line_number - 1
    end
end

function TextBuffer:clear()
    self.lines = {''}
    self.last_line_number = 1
end

return augment(TextBuffer)
