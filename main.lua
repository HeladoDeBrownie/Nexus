--[[
    This module is the LÖVE main entry point, evaluated after conf.lua. While
    all the LÖVE callbacks are defined here, most of the actual application
    logic happens in the UI modules (Modules/UI/*).
--]]

--# Requires

local Serialization
local Settings
local is_ctrl_down

--# Constants

local SECONDS_PER_TICK = 1 / 60

--# State

-- This module's state is contained in a table so it can be passed to the
-- console easily.
local Main = {}

--# Callbacks

function love.load()
    -- Look for modules in the Modules directory.
    love.filesystem.setRequirePath(
        'Modules/?.lua;' .. love.filesystem.getRequirePath()
    )

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

    is_ctrl_down = require'Helpers'.is_ctrl_down

    --[[
        Use nearest neighbor scaling in order to preserve pixel fidelity. Do
        this before loading any modules with images so that the setting is in
        place when images are loaded.
    --]]
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- While a key is held, repeat its key event after a short delay.
    love.keyboard.setKeyRepeat(true)

    Main.time = 0.0

    -- Create the UI.

    local UI = require'UI'
    local console = UI.Console:new{Main = Main}
    local scene_view = UI.SceneView:new()
    Main.main_widget = UI.Overlay:new(scene_view, console)
    love.resize(love.graphics.getDimensions())

    Main.session = require'Network/Session':new(scene_view)

    -- Copy prints to both standard output and the in-game console.

    local print = _G.print

    function _G.print(...)
        print(...)
        console:print(...)
    end
end

function love.update(time_delta)
    Main.session:process()
    Main.time = Main.time + time_delta

    while Main.time >= SECONDS_PER_TICK do
        Main.time = Main.time - SECONDS_PER_TICK
        Main.main_widget:tick()
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
    Main.main_widget:draw()
    love.graphics.draw(Main.main_widget:get_canvas())
end

function love.keypressed(key)
    Main.main_widget:on_key(key, true)
end

function love.keyreleased(key)
    Main.main_widget:on_key(key, false)
end

function love.mousepressed(x, y)
    Main.main_widget:on_press(x, y)
end

function love.resize(window_width, window_height)
    Main.main_widget:resize(window_width, window_height)
end

function love.textinput(text)
    Main.main_widget:on_text_input(text)
end

function love.wheelmoved(_, y)
    Main.main_widget:on_scroll(y, is_ctrl_down())
end
