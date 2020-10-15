local SceneView = {}

--# Requires

local Color = require'Color'
local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

--# Constants

local COLOR_SCHEME = require'ColorScheme':new(
    Color:new(315,  15,  90),

    {
        Color:new(285,  30,  80),
        Color:new(255,  45,  70),
        Color:new(240,  60,  60),
    },

    {
        Color:new(180,  15,  90),
        Color:new(210,  45,  70),
        Color:new(240,  75,  50),
    }
)

local IDENTITY_TRANSFORM = love.math.newTransform()

--# State

local sprite = love.graphics.newImage'Assets/Untitled.png'
local sprite2 = love.graphics.newImage'Assets/Untitled2.png'

--# Interface

function SceneView:initialize(scene, player_sprite)
    Widget.initialize(self, COLOR_SCHEME)
    Scalable.initialize(self, require'Settings'.UI.SceneView)
    self.entities_canvas = love.graphics.newCanvas()
    self.scene = scene
    self.keys_down = {}
    self.player_sprite = player_sprite
end

function SceneView:draw_foreground()
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

    self:apply_palette'background'
    love.graphics.draw(self.scene:get_chunk(0, 0))
    self:apply_palette'foreground'

    self.entities_canvas:renderTo(function ()
        love.graphics.push'all'
        love.graphics.clear()
        love.graphics.setShader()
        love.graphics.replaceTransform(IDENTITY_TRANSFORM)
        love.graphics.setBlendMode'replace'
        love.graphics.draw(sprite2, 24, 36)
        love.graphics.draw(self.player_sprite, player_x, player_y)
        love.graphics.pop()
    end)

    love.graphics.draw(self.entities_canvas)
end

function SceneView:on_unbound_key(key, down)
    self.keys_down[key] = down or nil
end

function SceneView:resize(...)
    Widget.resize(self, ...)
    self.entities_canvas = love.graphics.newCanvas(...)
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
