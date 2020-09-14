-- # Modules

-- Look for modules in the Modules directory.
package.path = './Modules/?.lua;' .. package.path

local lg = love.graphics
local lk = love.keyboard
local Console = require'UI/Console'

-- # State

local console
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

    console = Console.new'> '

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
    console:on_key(key, is_ctrl_down())
end

function love.wheelmoved(_, y)
    console:on_scroll(y, is_ctrl_down())
end

function love.textinput(text)
    console:on_text_input(text)
end

function love.draw()
    lg.push'all'
    console:on_draw(0, 0, lg.getDimensions())
    lg.pop()
end

function love.threaderror(thread, error_message)
    print(error_message)
end
