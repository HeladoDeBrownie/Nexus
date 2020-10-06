--[[
    This module is the LÖVE main entry point, evaluated after conf.lua. While
    all the LÖVE callbacks are defined here, most of the actual application
    logic happens in the UI modules (Modules/UI/*).
--]]

--# Modules

local Serialization
local Settings

--# Constants

local SECONDS_PER_TICK = 1 / 60

--# State

local main_widget
local scene
local time

--# Helpers

local function is_ctrl_down()
    return love.keyboard.isDown'lctrl' or love.keyboard.isDown'rctrl'
end

--# Callbacks

function love.load()
    -- Look for modules in the Modules directory.
    package.path = './Modules/?.lua;' .. package.path

    -- Make the mixin library available to all modules.
    local Mixin = require'Mixin'
    _G.augment = Mixin.augment
    _G.mix = Mixin.mix

    -- The serialization module is used both in this callback and in love.quit.
    Serialization = require'Serialization'

    --[[
        Safely require and, if necessary, patch the user settings. This only
        needs to be done the first time it's required on any given run, so any
        further uses of the settings module don't need to use safe_require.
    --]]
    Settings = Serialization.safe_require('Settings', require'Schemas/Settings')

    --[[
        Use nearest neighbor scaling in order to preserve pixel fidelity. Do
        this before loading any modules with images so that the setting is in
        place when images are loaded.
    --]]
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- While a key is held, repeat its key event after a short delay.
    love.keyboard.setKeyRepeat(true)

    scene = require'Scene':new()
    time = 0.0

    -- Create the UI.

    local UI = require'UI'
    local console = UI.Console:new'> '

    main_widget = UI.Overlay:new(
        UI.SceneView:new(scene),
        console
    )

    -- Copy prints to both standard output and the in-game console.

    local print = _G.print

    function _G.print(...)
        print(...)
        console:print(...)
    end
end

function love.update(time_delta)
    time = time + time_delta

    while time >= SECONDS_PER_TICK do
        time = time - SECONDS_PER_TICK
        main_widget:tick()
    end
end

function love.quit()
    -- Write any changes to the settings to the save directory.
    love.filesystem.write('Settings.lua',
        Serialization.to_lua_module(Settings)
    )
end

-- The remaining callbacks defined here are thin wrappers around UI code.

function love.draw()
    main_widget:draw(0, 0, love.graphics.getDimensions())
end

function love.keypressed(key)
    main_widget:on_key(key, true, is_ctrl_down())
end

function love.keyreleased(key)
    main_widget:on_key(key, false, is_ctrl_down())
end

function love.textinput(text)
    main_widget:on_text_input(text)
end

function love.wheelmoved(_, y)
    main_widget:on_scroll(y, is_ctrl_down())
end
