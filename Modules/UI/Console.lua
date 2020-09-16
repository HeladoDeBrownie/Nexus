local lg = love.graphics
local Font = require'Font'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local Console = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local console_metatable = {__index = Console}

function Console.new(prompt_string)
    local result = setmetatable({}, console_metatable)

    private[result] = {
        prompt_string = prompt_string,
        scrollback = TextBuffer.new(),
        input_buffer = TextBuffer.new(),
        scale = 4,
        font = Font.new(require'Assets/Carpincho Mono'),
    }

    result:print(prompt_string)
    return result
end

function Console:print(text)
    private[self].scrollback:append(text)
end

function Console:on_draw(x, y, width, height)
    local self_ = private[self]

    -- Draw the widget's background.
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)

    -- Use the widget's own scale.
    lg.scale(self_.scale)

    -- Show the prompt.
    self_.font:print(self_.scrollback:read() .. self_.input_buffer:read())
end

function Console:on_key(key, ctrl)
    local self_ = private[self]
    local input_buffer = self_.input_buffer

    if ctrl then
        if key == 'v' then
            -- Ctrl+V: Paste
            input_buffer:append(love.system.getClipboardText())
        elseif key == 'return' then
            -- Ctrl+Return: Insert newline
            input_buffer:append'\n'
        end
    else
        if key == 'backspace' then
            -- Backspace: Delete last character
            input_buffer:backspace()
        elseif key == 'return' then
            -- Return: Run command
            local scrollback = self_.scrollback
            local input = input_buffer:read()
            scrollback:append(input .. '\n')

            -- Use a separate thread so we don't crash the main thread.
            local thread = love.thread.newThread(input_buffer:read() .. '\n')
            self:register_associated_thread(thread)
            thread:start()
            thread:wait()

            input_buffer:clear()
            scrollback:append(self_.prompt_string)
        end
    end
end

function Console:on_scroll(units, ctrl)
    if ctrl then
        -- Ctrl+Scroll: Zoom in/out
        local self_ = private[self]
        self_.scale = math.max(1, math.min(self_.scale + units, 8))
    end
end

function Console:on_text_input(text)
    private[self].input_buffer:append(text)
end

function Widget:on_thread_error(error_message, _)
    private[self].scrollback:append(error_message .. '\n')
end

return Console
