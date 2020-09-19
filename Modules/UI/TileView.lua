local lg = love.graphics
local sprite = lg.newImage('Assets/Untitled.png')
local sprite2 = lg.newImage('Assets/Untitled2.png')
local Widget = require'UI/Widget'

local TileView = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local tile_view_metatable = {__index = TileView}

function TileView.new()
    local result = setmetatable({}, tile_view_metatable)

    private[result] = {
        x = 0,
        y = 0,
    }

    return result
end

function TileView:go(delta_x, delta_y)
    local self_ = private[self]
    self_.x = self_.x + delta_x
    self_.y = self_.y + delta_y
end

function TileView:on_draw(x, y, width, height)
    local self_ = private[self]

    local base_x, base_y = lg.inverseTransformPoint(
        width / 2,
        height / 2
    )

    local girl_x, girl_y = x + 12 * self_.x, y + 12 * self_.y

    lg.translate(
        math.floor(base_x - girl_x - 6),
        math.floor(base_y - girl_y - 6)
    )

    lg.draw(sprite, girl_x, girl_y)
    lg.draw(sprite2, x + 24, y + 36)
end

function TileView:on_key(key, ctrl)
    if not ctrl then
        if key == 'w' then
            self:go( 0, -1)
        elseif key == 'a' then
            self:go(-1,  0)
        elseif key == 's' then
            self:go( 0,  1)
        elseif key == 'd' then
            self:go( 1,  0)
        end
    end
end

function TileView:on_scroll(units, ctrl)
end

function TileView:on_text_input(text)
end

return TileView
