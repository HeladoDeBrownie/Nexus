local Console = {}

--# Requires

local Color = require'Color'
local Scalable = require'UI/Scalable'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

--# Interface

function Console:initialize(prompt_string)
    Widget.initialize(self)
    Scalable.initialize(self, require'Settings'.UI.Console)

    self.environment = setmetatable({}, {__index = _G})

    self.prompt_string = prompt_string
    self.scrollback = TextBuffer:new()
    self.input_buffer = TextBuffer:new()
    self.font = require'Font':new(require'Assets/Carpincho Mono')

    self:set_palette(
        {Color:new(0, 0, 0):to_normalized_rgba()},
        {0.25, 0.25, 0.25, 1},
        {0.5, 0.5, 0.5, 1},
        {1, 1, 1, 1}
    )

    self:bind('Backspace', Console.backspace)
    self:bind('Return', Console.run_command)
    self:bind('Ctrl+Return', Console.insert_newline)
    self:bind('Ctrl+V', Console.paste)
end

function Console:print(...)
    local arguments = {...}

    for index = 1, select('#', ...) do
        self.scrollback:append(tostring(arguments[index]) .. '\n')
    end
end

function Console:draw_widget()
    local width, height = self:get_dimensions()
    self:apply_scale()

    -- The console's text is the scrollback followed by the current
    -- input.
    local text =
        self.scrollback:read() ..
        self.prompt_string ..
        self.input_buffer:read()

    -- Scroll so that the latest text is on-screen and then some.

    local _, transformed_height =
        love.graphics.inverseTransformPoint(0, height)

    love.graphics.translate(0, math.min(0,
        transformed_height - self.font:compute_height(text, width) - 12)
    )

    -- Display the text.
    self.font:print(text)
end

function Console:on_text_input(text)
    self.input_buffer:append(text)
end

function Console:insert_newline()
    self.input_buffer:append'\n'
end

function Console:backspace()
    self.input_buffer:backspace()
end

function Console:paste()
    self.input_buffer:append(love.system.getClipboardText())
end

function Console:run_command()
    local input_buffer = self.input_buffer
    local input = input_buffer:read()
    self:print(self.prompt_string .. input)

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
        self:print(load_error_message)
    else
        local function handle_result(_, ...)
            self:print(...)
        end

        handle_result(pcall(chunk))
    end

    input_buffer:clear()
end

return augment(mix{Widget, Scalable, Console})
