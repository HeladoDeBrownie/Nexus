local Color = require'Color'
local Scalable = require'UI/Scalable'
local TextBuffer = require'TextBuffer'
local Widget = require'UI/Widget'

local Console = augment(mix{Widget, Scalable})

--# Constants

Console.background_image = love.graphics.newImage'Assets/Console Background.png'
Console.background_image:setWrap('repeat', 'repeat')

Console.color_scheme = require'ColorScheme':new(
    Color:new(0, 0, 0),

    {
        Color:new(  0,   0,  4),
        Color:new(  0,   0,  6),
        Color:new(  0,   0,  8),
    },

    {
        Color:new(  0,   0,  25),
        Color:new(  0,   0,  50),
        Color:new(  0,   0, 100),
    }
)

--# Interface

function Console:initialize(environment, prompt_string)
    Widget.initialize(self)
    Scalable.initialize(self, require'Settings'.UI.Console, 2, 8)

    self.environment = setmetatable(environment or {}, {__index = _G})

    self.prompt_string = prompt_string or '> '
    self.scrollback = TextBuffer:new()
    self.input_buffer = TextBuffer:new()
    self.scrolled_back_amount = 0
    self.font = require'Font':new(require'Assets/Carpincho Mono')
    self.quad = love.graphics.newQuad(0, 0, 0, 0, Console.background_image:getDimensions())

    self:bind('Backspace',      Console.backspace)
    self:bind('Return',         Console.run_command)
    self:bind('Ctrl+Return',    Console.insert_newline)
    self:bind('Ctrl+V',         Console.paste)

    self:print'Be careful! Running arbitrary Lua code can break your game.'
end

function Console:append(...)
    self.scrolled_back_amount = 0
    self.input_buffer:append(...)
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

function Console:draw_background()
    local width, height = self:get_dimensions()
    self:apply_scale()
    love.graphics.draw(self.background_image, self.quad, 0, 0)
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

    local text_height = self.font:compute_height(text, width)

    if self.scrolled_back_amount > text_height - transformed_height then
        self.scrolled_back_amount = text_height - transformed_height
    end

    love.graphics.translate(0, math.min(0,
        transformed_height - text_height + self.scrolled_back_amount)
    )

    self.font:print(text)
end

function Console:on_scroll(...)
    local units, ctrl = ...

    if not ctrl then
        self.scrolled_back_amount =
            math.max(0, self.scrolled_back_amount + 9 * units)
    else
        return Scalable.on_scroll(self, ...)
    end
end

function Console:on_text_input(text)
    self:append(text)
end

function Console:resize(...)
    Widget.resize(self, ...)
    local width, height = ...
    self.quad:setViewport(0, 0, width, height)
end

function Console:insert_newline()
    self:append'\n'
end

function Console:backspace()
    self.scrolled_back_amount = 0
    self.input_buffer:backspace()
end

function Console:paste()
    self:append(love.system.getClipboardText())
end

function Console:run_command()
    self.scrolled_back_amount = 0
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
            if select('#', ...) > 0 then
                self:print(...)
            end
        end

        handle_result(pcall(chunk))
    end

    input_buffer:clear()
end

--#

return Console
