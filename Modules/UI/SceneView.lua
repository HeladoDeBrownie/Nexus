local SceneView = {}

--# Requires

local Color = require'Color'
local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

--# Constants

local COLOR_SCHEME = require'ColorScheme':new(
    Color:new(0, 0, 0),

    {
        Color:new(  0,   0,  19),
        Color:new(  0,   0,  58),
        Color:new(  0,   0,  98),
    },

    {
        Color:new(134, 100,  89),
        Color:new(156, 100,  52),
        Color:new( 30,  16,  37),
    }
)

--# State

local sprite = love.graphics.newImage'Assets/Untitled.png'
local sprite2 = love.graphics.newImage'Assets/Untitled2.png'

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
    self:set_palette(COLOR_SCHEME:to_normalized_rgba'background')
end

function SceneView:apply_foreground_palette()
    self:set_palette(COLOR_SCHEME:to_normalized_rgba'foreground')
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

    love.graphics.draw(self.scene:get_chunk(0, 0))
    self:apply_foreground_palette()
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
