-- # Modules

local lg = love.graphics
local lk = love.keyboard
local Font = require'Font'
local TextBuffer = require'TextBuffer'

-- # State

local buffer
local font
local shader

-- # Helpers

local function is_ctrl_down()
    return lk.isDown'lctrl' or lk.isDown'rctrl'
end

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

-- # Callbacks

function love.load()
    -- Use nearest neighbor scaling in order to preserve pixel fidelity.
    lg.setDefaultFilter('nearest', 'nearest')

    lk.setKeyRepeat(true)

    buffer = TextBuffer.new()
    font = Font.new(require'Assets/Font')

    -- Set up the palette swap pixel shader.

    shader = lg.newShader'palette_swap.glsl'

    -- Tell the shader which colors to swap in.
    shader:sendColor('palette',
        -- For now, these are just some sample PICO-8 colors.
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )

    lg.setShader(shader)
end

function love.keypressed(key)
    if key == 'backspace' then
        buffer:backspace()
    elseif key == 'return' then
        buffer:append'\n'
    elseif is_ctrl_down() then
        if key == 'v' then
            buffer:append(love.system.getClipboardText())
        end
    end
end

function love.textinput(text)
    buffer:append(text)
end

function love.draw()
    -- Save all graphical state for easy reversion later.
    lg.push'all'

    -- Since lg.clear() bypasses the shader, draw a solid background instead.
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', 0, 0, lg.getDimensions())
    lg.setColor(1, 1, 1)

    -- Scale everything up so that the text is readable.
    -- This will be set by a setting later.
    lg.scale(8)

    -- Display some sample text while things are still largely unimplemented.
    font:print('type here: ' .. buffer:read())

    -- Revert all graphical state.
    lg.pop()
end
