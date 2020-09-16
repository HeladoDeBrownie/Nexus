-- # Modules

-- Look for modules in the Modules directory.
package.path = './Modules/?.lua;' .. package.path

local lg = love.graphics
local lk = love.keyboard
local Console = require'UI/Console'
local Overlay = require'UI/Overlay'
local Serialization = require'Serialization'

-- # State

local main_widget
local settings
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
    settings = require'Settings'

    -- Use nearest neighbor scaling in order to preserve pixel fidelity.
    lg.setDefaultFilter('nearest', 'nearest')

    lk.setKeyRepeat(true)

    main_widget = Overlay.new(Console.new'1> ', Console.new'2> ')

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
    main_widget:on_key(key, is_ctrl_down())
end

function love.wheelmoved(_, y)
    main_widget:on_scroll(y, is_ctrl_down())
end

function love.textinput(text)
    main_widget:on_text_input(text)
end

function love.draw()
    lg.push'all'
    main_widget:on_draw(0, 0, lg.getDimensions())
    lg.pop()
end

function love.threaderror()
    -- Swallow thread errors; if we care about them, we will ask for them.
end

function love.quit()
    love.filesystem.write('Settings.lua',
        Serialization.serialize_table(settings)
    )
end
