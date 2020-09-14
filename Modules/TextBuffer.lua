local utf8 = require'utf8'

local TextBuffer = {}
local private = setmetatable({}, {__mode = 'k'})
local text_buffer_metatable = {__index = TextBuffer}

function TextBuffer.new()
    local result = setmetatable({}, text_buffer_metatable)

    private[result] = {
        text = '',
    }

    return result
end

function TextBuffer:read()
    return private[self].text
end

function TextBuffer:clear()
    private[self].text = ''
end

function TextBuffer:append(text)
    private[self].text = private[self].text .. text
end

function TextBuffer:backspace()
    local text = private[self].text

    if utf8.len(text) > 0 then
        private[self].text = text:sub(1, utf8.offset(text, -1) - 1)
    end
end

return TextBuffer
