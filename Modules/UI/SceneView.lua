local SceneView = {}

--# Requires

local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

--# State

local sprite = love.graphics.newImage'Assets/Untitled.png'
local sprite2 = love.graphics.newImage'Assets/Untitled2.png'

--# Helpers

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

--# Methods

function SceneView:initialize(scene)
    Widget.initialize(self)
    Scalable.initialize(self, require'Settings'.UI.SceneView)
    self.scene = scene

    self:set_palette(
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )
end

function SceneView:on_draw(x, y, width, height)
    self:apply_scale()

    local base_x, base_y = love.graphics.inverseTransformPoint(
        width / 2,
        height / 2
    )

    local player_x, player_y = self.scene:get_player_position()
    local player_sx, player_sy = x + 12 * player_x, y + 12 * player_y

    love.graphics.translate(
        math.floor(base_x - player_sx - 6),
        math.floor(base_y - player_sy - 6)
    )

    love.graphics.draw(sprite, player_sx, player_sy)
    love.graphics.draw(sprite2, x + 24, y + 36)
end

function SceneView:on_key(key, ctrl)
    local scene = self.scene

    if not ctrl then
        if key == 'w' then
            scene:go( 0, -1)
        elseif key == 'a' then
            scene:go(-1,  0)
        elseif key == 's' then
            scene:go( 0,  1)
        elseif key == 'd' then
            scene:go( 1,  0)
        end
    end
end

--# Export

return mix{Widget, Scalable, SceneView}
