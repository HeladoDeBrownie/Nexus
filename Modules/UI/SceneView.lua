local CanvasBufferedWidget = require'UI/CanvasBufferedWidget'
local Chunk = require'Chunk'
local Color = require'Color'
local Scalable = require'UI/Scalable'
local Sprite = require'Sprite'

local SceneView = augment(mix{CanvasBufferedWidget, Scalable})

--# Constants

SceneView.minimum_scale = 4
SceneView.maximum_scale = 16
SceneView.default_scale = 8

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
local INDICATOR = love.graphics.newImage'Assets/Indicator.png'
local INDICATOR_WIDTH, INDICATOR_HEIGHT = INDICATOR:getDimensions()

--# Interface

function SceneView:initialize(scene)
    CanvasBufferedWidget.initialize(self, COLOR_SCHEME)

    Scalable.initialize(self, require'Settings'.UI.SceneView,
        self.minimum_scale, self.maximum_scale
    )

    self.scene = scene
    self.keys_down = {}
    self.viewpoint_entity = nil
    self.active_color = 0

    for color = 0, 3 do
        self:bind(tostring(color), SceneView.set_active_color, color)
    end

    -- transient draw state
    self.entities_canvas = love.graphics.newCanvas()
    self.transform = love.math.newTransform()
end

function SceneView:get_scene()
    return self.scene
end

function SceneView:set_scene(new_scene)
    self.scene = new_scene
    self.viewpoint_entity = nil
end

function SceneView:get_session()
    return self.session
end

function SceneView:set_session(new_session)
    self.session = new_session
end

function SceneView:get_viewpoint_entity()
    return self.viewpoint_entity
end

function SceneView:set_viewpoint_entity(new_viewpoint_entity)
    self.viewpoint_entity = new_viewpoint_entity
end

function SceneView:set_active_color(new_active_color)
    self.active_color = new_active_color
end

function SceneView:get_viewpoint_position()
    if self.viewpoint_entity == nil then
        return 0, 0
    else
        return self.scene:get_entity_position(self.viewpoint_entity)
    end
end

function SceneView:paint()
    self.transform:reset()
    local width, height = self:get_dimensions()
    local viewpoint_x, viewpoint_y = self:get_viewpoint_position()
    self.transform:scale(self:get_scale())
    local base_x, base_y = self.transform:inverseTransformPoint(width / 2, height / 2)

    self.transform:translate(
        math.floor(base_x - viewpoint_x - Sprite.WIDTH / 2),
        math.floor(base_y - viewpoint_y - Sprite.HEIGHT / 2)
    )

    CanvasBufferedWidget.paint(self)
end

function SceneView:paint_background()
    CanvasBufferedWidget.paint_background(self)
    love.graphics.applyTransform(self.transform)
    love.graphics.draw(self.scene:get_chunk(0, 0):get_image(), 0 * Chunk.PIXEL_WIDTH, 0 * Chunk.PIXEL_HEIGHT)
    love.graphics.draw(self.scene:get_chunk(1, 1):get_image(), 1 * Chunk.PIXEL_WIDTH, 1 * Chunk.PIXEL_HEIGHT)
end

function SceneView:paint_foreground()
    love.graphics.replaceTransform(self.transform)

    self.entities_canvas:renderTo(function ()
        love.graphics.push'all'
        love.graphics.clear()
        love.graphics.setShader()
        love.graphics.setBlendMode'replace'

        local viewpoint_entity_id = self:get_viewpoint_entity()

        -- Draw the non-viewpoint entities.
        for entity_id in self.scene:each_entity() do
            if entity_id ~= viewpoint_entity_id then
                local sprite, x, y = self.scene:get_entity_data(entity_id)
                love.graphics.draw(sprite:get_image(), x, y)
            end
        end

        -- Draw the viewpoint entity above all others.
        if viewpoint_entity_id ~= nil then
            local sprite, x, y = self.scene:get_entity_data(viewpoint_entity_id)
            love.graphics.draw(sprite:get_image(), x, y)
        end

        -- Draw indicators above all non-viewpoint entities.
        for entity_id in self.scene:each_entity() do
            if entity_id ~= viewpoint_entity_id then
                local x, y = self.scene:get_entity_position(entity_id)
                love.graphics.draw(INDICATOR, x + math.floor((Sprite.WIDTH - INDICATOR_WIDTH) / 2), y - INDICATOR_HEIGHT - 1)
            end
        end

        love.graphics.pop()
    end)

    love.graphics.replaceTransform(IDENTITY_TRANSFORM)
    love.graphics.draw(self.entities_canvas)
end

function SceneView:unbound_key(key, down)
    self.keys_down[key] = down or nil
end

function SceneView:press(screen_x, screen_y)
    local object_type, object, offset_x, offset_y =
        self:get_object_from_screen(screen_x, screen_y)

    if object == self.viewpoint_entity then
        self.scene:get_entity_sprite(object):set_pixel(
            offset_x, offset_y,
            self.active_color
        )

        self:broadcast_sprite()
    end
end

function SceneView:get_object_from_screen(screen_x, screen_y)
    local scene_x, scene_y =
        self.transform:inverseTransformPoint(screen_x, screen_y)

    local entity_id = self.viewpoint_entity

    if entity_id ~= nil then
        local entity_x, entity_y = self.scene:get_entity_position(entity_id)

        if
            entity_x <= scene_x and scene_x < entity_x + Sprite.WIDTH and
            entity_y <= scene_y and scene_y < entity_y + Sprite.HEIGHT
        then
            return 'entity', entity_id, scene_x - entity_x, scene_y - entity_y
        end
    end
end

function SceneView:resize(...)
    CanvasBufferedWidget.resize(self, ...)
    self.entities_canvas = love.graphics.newCanvas(...)
end

function SceneView:tick()
    local viewpoint_entity = self.viewpoint_entity

    if viewpoint_entity ~= nil then
        local delta_x, delta_y = 0, 0

        if self.keys_down['w'] then
            delta_y = delta_y - 1
        end

        if self.keys_down['a'] then
            delta_x = delta_x - 1
        end

        if self.keys_down['s'] then
            delta_y = delta_y + 1
        end

        if self.keys_down['d'] then
            delta_x = delta_x + 1
        end

        if delta_x ~= 0 or delta_y ~= 0 then
            self.scene:move_entity(viewpoint_entity, delta_x, delta_y)
            self:broadcast_position()
        end
    end
end

function SceneView:broadcast_position()
    local x, y = self.scene:get_entity_position(self.viewpoint_entity)

    self.session:broadcast_message{
        type = 'place',
        origin = self.viewpoint_entity,
        x = x, y = y,
    }
end

function SceneView:broadcast_sprite()
    local sprite = self.scene:get_entity_sprite(self.viewpoint_entity)

    self.session:broadcast_message{
        type = 'sprite',
        origin = self.viewpoint_entity,
        sprite_byte_string = sprite:to_byte_string(),
    }
end

--#

return SceneView
