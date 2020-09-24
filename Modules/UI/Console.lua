local lg = love.graphics
local Font = require'Font'
local ConsoleSettings = require'Settings'.UI.Console
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local Console = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local console_metatable = {__index = Console}

function Console.new(prompt_string)
    local result = setmetatable(Widget.new(), console_metatable)

    private[result] = {
        environment = setmetatable({
            print = function (...)
                return result:print(true, ...)
            end,
        }, {__index = _G}),

        prompt_string = prompt_string,
        scrollback = TextBuffer.new(),
        input_buffer = TextBuffer.new(),
        font = Font.new(require'Assets/Carpincho Mono'),
    }

    result:print(false, prompt_string)
    result:set_palette(
        {0, 0, 0, 1},
        {0.25, 0.25, 0.25, 1},
        {0.5, 0.5, 0.5, 1},
        {1, 1, 1, 1}
    )
    return result
end

function Console:print(with_final_line_break, ...)
    local self_ = private[self]
    local arguments = {...}

    for index = 1, select('#', ...) do
        self_.scrollback:append(tostring(arguments[index]) .. '\n')
    end

    if not with_final_line_break then
        self_.scrollback:backspace()
    end
end

function Console:on_draw(x, y, width, height)
    local self_ = private[self]

    lg.scale(ConsoleSettings.scale)

    -- The console's text is the scrollback followed by the current input.
    local text = self_.scrollback:read() .. self_.input_buffer:read()

    -- Scroll so that the latest text is on-screen and then some.

    local _, transformed_height = lg.inverseTransformPoint(0, height)

    lg.translate(0, math.min(0,
        transformed_height - self_.font:compute_height(text, width) - 12)
    )

    -- Display the text.
    self_.font:print(text)
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
            local input = input_buffer:read()
            self:print(true, input)

            local chunk, load_error_message = load(input_buffer:read(), 'player input', 't', self_.environment)

            if chunk == nil then
                chunk, load_error_message = load('return ' .. input_buffer:read(), 'player input', 't', self_.environment)
            end

            if chunk == nil then
                self:print(true, load_error_message)
            else
                local function handle_result(_, ...)
                    self:print(true, ...)
                end

                handle_result(pcall(chunk))
            end

            input_buffer:clear()
            self:print(false, self_.prompt_string)
        end
    end
end

function Console:on_scroll(units, ctrl)
    if ctrl then
        -- Ctrl+Scroll: Zoom in/out
        ConsoleSettings.scale =
            math.max(2, math.min(ConsoleSettings.scale + units, 8))
    end
end

function Console:on_text_input(text)
    private[self].input_buffer:append(text)
end

return Console
