local Console = {}

--# Requires

local Color = require'Color'
local Scalable = require'UI/Scalable'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

--# Constants

Console.color_scheme = require'ColorScheme':new(
    Color:new(0, 0, 0),

    {
        Color:new(  0,   0,   0),
        Color:new(  0,   0,   0),
        Color:new(  0,   0,   0),
    },

    {
        Color:new(  0,   0,  25),
        Color:new(  0,   0,  50),
        Color:new(  0,   0, 100),
    }
)

--# Interface

function Console:initialize(prompt_string)
    Widget.initialize(self)
    Scalable.initialize(self, require'Settings'.UI.Console)

    self.environment = setmetatable({}, {__index = _G})

    self.prompt_string = prompt_string
    self.scrollback = TextBuffer:new()
    self.input_buffer = TextBuffer:new()
    self.font = require'Font':new(require'Assets/Carpincho Mono')

    self:bind('Backspace',      Console.backspace)
    self:bind('Return',         Console.run_command)
    self:bind('Ctrl+Return',    Console.insert_newline)
    self:bind('Ctrl+V',         Console.paste)
end

function Console:print(...)
    local arguments = {...}
    local output = ''

    -- select('#', ...) must be used here instead of #arguments because we want
    -- to handle nils, but the # operator has undefined behavior on sequences
    -- that include them.
    for index = 1, select('#', ...) do
        local output_item = tostring(arguments[index])

        if output == '' then
            output = output_item
        else
            output = output .. '\t' .. output_item
        end
    end

    self.scrollback:append(output .. '\n')
end

function Console:draw_foreground()
    local width, height = self:get_dimensions()
    self:apply_scale()

    -- Display the console's text scrolled so that the prompt is in view and
    -- there's at least one blank line after it to act as a visual buffer.

    local text =
        self.scrollback:read() ..
        self.prompt_string ..
        self.input_buffer:read() ..
        '\n'

    local _, transformed_height =
        love.graphics.inverseTransformPoint(0, height)

    love.graphics.translate(0, math.min(0,
        transformed_height - self.font:compute_height(text, width))
    )

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
