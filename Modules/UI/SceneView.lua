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

--# Interface

function SceneView:initialize(scene, player_sprite)
    Widget.initialize(self)
    Scalable.initialize(self, require'Settings'.UI.SceneView)
    self.scene = scene
    self.keys_down = {}
    self.player_sprite = player_sprite
    self:apply_background_palette()
end

function SceneView:apply_background_palette()
    local background_color = {0, 0, 0, 1}

    self:set_palette(
        background_color,
        background_color,
        background_color,
        background_color
    )
end

function SceneView:apply_tile_palette()
    self:set_palette(
        {0, 0, 0, 0},
        {rgb24_to_love_color( 50,  50,  50)},
        {rgb24_to_love_color(150, 150, 150)},
        {rgb24_to_love_color(250, 250, 250)}
    )
end

function SceneView:apply_entity_palette()
    self:set_palette(
        {0, 0, 0, 0},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )
end

function SceneView:draw_widget()
    local width, height = self:get_dimensions()
    self:apply_scale()

    local base_x, base_y = love.graphics.inverseTransformPoint(
        width / 2,
        height / 2
    )

    local player_x, player_y = self.scene:get_player_position()
    local player_sx, player_sy = player_x, player_y

    love.graphics.translate(
        math.floor(base_x - player_sx - 6),
        math.floor(base_y - player_sy - 6)
    )

    self:apply_tile_palette()
    love.graphics.draw(self.scene:get_chunk(0, 0))
    self:apply_entity_palette()
    love.graphics.draw(self.player_sprite, player_sx, player_sy)
    love.graphics.draw(sprite2, 24, 36)
    self:apply_background_palette()
end

function SceneView:on_unbound_key(key, down)
    self.keys_down[key] = down or nil
end

function SceneView:tick()
    if self.keys_down['w'] then
        self.scene:go( 0, -1)
    end

    if self.keys_down['a'] then
        self.scene:go(-1,  0)
    end

    if self.keys_down['s'] then
        self.scene:go( 0,  1)
    end

    if self.keys_down['d'] then
        self.scene:go( 1,  0)
    end
end

return augment(mix{Widget, Scalable, SceneView})
