local Scene = {}
local private = setmetatable({}, {__mode = 'k'})
local scene_metatable = {__index = Scene}

function Scene.new()
    local self = setmetatable({}, scene_metatable)

    private[self] = {
        x = 0,
        y = 0,
    }

    return self
end

function Scene:get_player_position()
    local self_ = private[self]
    return self_.x, self_.y
end

function Scene:go(delta_x, delta_y)
    local self_ = private[self]
    self_.x = self_.x + delta_x
    self_.y = self_.y + delta_y
end

return Scene
