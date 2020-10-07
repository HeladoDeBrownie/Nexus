-- Helpers that are used by more than one module go here.

local Helpers = {}

function Helpers.is_ctrl_down()
    return love.keyboard.isDown'lctrl' or love.keyboard.isDown'rctrl'
end

return Helpers
