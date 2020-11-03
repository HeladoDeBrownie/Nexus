local TextBuffer = {}

--# Requires

local RingBuffer = require'RingBuffer'
local utf8 = require'utf8'

--# Constants

TextBuffer.scrollback_limit = 1000

--# Interface

function TextBuffer:initialize(scrollback_limit)
    self.scrollback_limit = scrollback_limit
    self:clear()
end

function TextBuffer:read()
    local joined_text = ''

    for line_number = 1, self.buffer:get_size() do
        joined_text =
            joined_text .. self.buffer:get_element_at(line_number) .. '\n'
    end

    return joined_text:sub(1, -2)
end

function TextBuffer:append(text)
    local buffer = self.buffer

    for line in (text .. '\n'):gmatch'([^\n]*)\n' do
        buffer:set_element_at(buffer:get_size(), buffer:get_element_at(buffer:get_size()) .. line)
        buffer:push''
    end

    self.buffer:pop()
end

function TextBuffer:backspace()
    local buffer = self.buffer
    local line = buffer:get_element_at(self.buffer:get_size())

    if utf8.len(line) > 0 then
        buffer:set_element_at(buffer:get_size(),
            line:sub(1, utf8.offset(line, -1) - 1))
    elseif buffer:get_size() > 1 then
        self.buffer:pop()
    end
end

function TextBuffer:clear()
    self.buffer = RingBuffer:new(self.scrollback_limit)
    self.buffer:push''
end

return augment(TextBuffer)
