local Color = require'Color'
local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

local SceneView = augment(mix{Widget, Scalable})

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

--# Interface

function SceneView:initialize(scene)
    Widget.initialize(self, COLOR_SCHEME)
    Scalable.initialize(self, require'Settings'.UI.SceneView)
    self.scene = scene
    self.keys_down = {}
    self.viewpoint_entity = nil

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

function SceneView:get_viewpoint_position()
    if self.viewpoint_entity == nil then
        return 0, 0
    else
        return self.scene:get_entity_position(self.viewpoint_entity)
    end
end

function SceneView:before_drawing()
    Widget.before_drawing(self)
    self.transform:reset()
    local width, height = self:get_dimensions()
    local viewpoint_x, viewpoint_y = self:get_viewpoint_position()
    self.transform:scale(self:get_scale())
    local base_x, base_y = self.transform:inverseTransformPoint(width / 2, height / 2)

    self.transform:translate(
        math.floor(base_x - viewpoint_x - 6),
        math.floor(base_y - viewpoint_y - 6)
    )
end

function SceneView:draw_background()
    Widget.draw_background(self)
    love.graphics.replaceTransform(self.transform)
    love.graphics.draw(self.scene:get_chunk(0, 0))
end

function SceneView:draw_foreground()
    love.graphics.replaceTransform(self.transform)

    self.entities_canvas:renderTo(function ()
        love.graphics.push'all'
        love.graphics.clear()
        love.graphics.setShader()
        love.graphics.setBlendMode'replace'

        for entity_id in self.scene:each_entity() do
            local sprite, x, y = self.scene:get_entity_data(entity_id)
            love.graphics.draw(sprite:get_image(), x, y)
        end

        local viewpoint_entity_id = self:get_viewpoint_entity()

        if viewpoint_entity_id ~= nil then
            local sprite, x, y = self.scene:get_entity_data(viewpoint_entity_id)
            love.graphics.draw(sprite:get_image(), x, y)
        end

        love.graphics.pop()
    end)

    love.graphics.replaceTransform(IDENTITY_TRANSFORM)
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
