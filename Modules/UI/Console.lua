local ConsoleSettings = require'Settings'.UI.Console
local TextBuffer = require'TextBuffer'

return make_class{
    superclass = require'UI/Widget',

    new = function (self, super, prompt_string)
        super()

        self.environment = setmetatable({
            print = function (...)
                return self:print(true, ...)
            end,
        }, {__index = _G})

        self.prompt_string = prompt_string
        self.scrollback = TextBuffer.new()
        self.input_buffer = TextBuffer.new()
        self.font = require'Font'.new(require'Assets/Carpincho Mono')
        self:print(false, prompt_string)

        self:set_palette(
            {0, 0, 0, 1},
            {0.25, 0.25, 0.25, 1},
            {0.5, 0.5, 0.5, 1},
            {1, 1, 1, 1}
        )
    end,

    methods = {
        print = function (self, with_final_line_break, ...)
            local arguments = {...}

            for index = 1, select('#', ...) do
                self.scrollback:append(tostring(arguments[index]) .. '\n')
            end

            if not with_final_line_break then
                self.scrollback:backspace()
            end
        end,

        on_draw = function (self, x, y, width, height)
            love.graphics.scale(ConsoleSettings.scale)

            -- The console's text is the scrollback followed by the current
            -- input.
            local text = self.scrollback:read() .. self.input_buffer:read()

            -- Scroll so that the latest text is on-screen and then some.

            local _, transformed_height =
                love.graphics.inverseTransformPoint(0, height)

            love.graphics.translate(0, math.min(0,
                transformed_height - self.font:compute_height(text, width) - 12)
            )

            -- Display the text.
            self.font:print(text)
        end,

        on_key = function (self, key, ctrl)
            local input_buffer = self.input_buffer

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

                    local chunk, load_error_message = load(
                        input_buffer:read(),
                        'player input',
                        't',
                        self.environment
                    )

                    if chunk == nil then
                        chunk, load_error_message = load(
                            'return ' .. input_buffer:read(),
                            'player input',
                            't',
                            self.environment
                        )
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
                    self:print(false, self.prompt_string)
                end
            end
        end,

        on_scroll = function (self, units, ctrl)
            if ctrl then
                -- Ctrl+Scroll: Zoom in/out
                ConsoleSettings.scale =
                    math.max(2, math.min(ConsoleSettings.scale + units, 8))
            end
        end,

        on_text_input = function (self, text)
            self.input_buffer:append(text)
        end,
    },
}
