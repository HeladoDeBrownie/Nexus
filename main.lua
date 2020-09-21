--[[
    This module is the LÖVE main entry point, evaluated after conf.lua. While
    all the LÖVE callbacks are defined here, most of the actual application
    logic happens in the UI modules (Modules/UI/*).
--]]

-- # State

-- Almost all state is handled in widget code.
local main_widget

-- # Helpers

local function is_ctrl_down()
    return love.keyboard.isDown'lctrl' or love.keyboard.isDown'rctrl'
end

-- # Callbacks

function love.load()
    -- Look for modules in the Modules directory.
    package.path = './Modules/?.lua;' .. package.path

    --[[
        Use nearest neighbor scaling in order to preserve pixel fidelity. Do
        this before loading any modules so that the setting is in place when
        images are loaded.
    --]]
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- While a key is held, repeat its key event after a short delay.
    love.keyboard.setKeyRepeat(true)

    local UI = require'UI'
    main_widget = UI.Overlay.new(UI.TileView.new(), UI.Console.new'> ')
end

function love.quit()
    -- Write any changes to the settings to the save directory.
    love.filesystem.write('Settings.lua',
        require'Serialization'.to_lua_module(require'Settings')
    )
end

-- The remaining callbacks defined here are thin wrappers around widget code.

function love.draw()
    main_widget:draw(0, 0, lg.getDimensions())
end

function love.keypressed(key)
    main_widget:on_key(key, is_ctrl_down())
end

function love.textinput(text)
    main_widget:on_text_input(text)
end

function love.wheelmoved(_, y)
    main_widget:on_scroll(y, is_ctrl_down())
end
