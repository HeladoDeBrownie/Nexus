local Chunk = require'Chunk'
local Sprite = require'Sprite'
local Scalable = require'UI/Scalable'
local Widget = require'UI/Widget'

local SessionView = augment(mix{Widget, Scalable})

-- # Constants

SessionView.minimum_scale = 2
SessionView.maximum_scale = 16
SessionView.default_scale = 8

local INDICATOR = love.graphics.newImage'Assets/Indicator.png'
local INDICATOR_WIDTH, INDICATOR_HEIGHT = INDICATOR:getDimensions()

-- # Interface

function SessionView:initialize(session)
    Widget.initialize(self)

    Scalable.initialize(self, require'Settings'.UI.SceneView,
        self.minimum_scale, self.maximum_scale
    )

    self:set_session(session)
    self:set_active_color(0)
    self.keys_down = {}

    -- transient draw state
    self.entity_canvas = love.graphics.newCanvas(self:get_dimensions())
    self.transform = love.math.newTransform()

    for color = 0, 3 do
        self:bind(tostring(color), SessionView.set_active_color, color)
    end
end

function SessionView:get_session()
    return self.session
end

function SessionView:get_active_color()
    return self.active_color
end

function SessionView:get_area()
    return self:get_session():get_area()
end

function SessionView:get_player()
    return self:get_session():get_player()
end

function SessionView:set_session(new_session)
    self.session = new_session
    self:set_color_scheme(self:get_area():get_color_scheme())
    -- TODO: listen for changes to color scheme
end

function SessionView:set_active_color(new_active_color)
    self.active_color = new_active_color
end

function SessionView:compute_entity_from_screen_position(screen_x, screen_y)
    -- TODO: Make this work on any entity, and generalize to chunks as well.

    local area_x, area_y =
        self.transform:inverseTransformPoint(screen_x, screen_y)

    local player = self:get_player()
    local player_x, player_y = self:get_area():get_entity_position(player)

    if
        player_x <= area_x and area_x < player_x + Sprite.WIDTH and
        player_y <= area_y and area_y < player_y + Sprite.HEIGHT
    then
        return player, area_x - player_x, area_y - player_y
    end
end

function SessionView:compute_view_area_position()
    local x, y = self:get_area():get_entity_position(self:get_player())
    return x + math.floor(Sprite.WIDTH / 2), y + math.floor(Sprite.HEIGHT / 2)
end

-- ## Overrides

function SessionView:paint()
    self.transform:reset()
    local width, height = self:get_dimensions()
    self.transform:translate(width / 2, height / 2)
    self:apply_scale(self.transform)
    local position_x, position_y = self:compute_view_area_position()
    self.transform:translate(-position_x, -position_y)
    Widget.paint(self)
end

function SessionView:paint_background()
    Widget.paint_background(self)
    love.graphics.applyTransform(self.transform)
    local area = self:get_area()

    -- TODO: loop over nearby chunks instead of drawing fixed ones
    love.graphics.draw(area:get_chunk(0, 0):get_image(), 0, 0)
    love.graphics.draw(area:get_chunk(1, 1):get_image(), Chunk.PIXEL_WIDTH, Chunk.PIXEL_HEIGHT)
end

function SessionView:paint_foreground()
    -- Stage entity drawing using a separate canvas so that we can use the
    -- "replace" blend mode, which makes entities erase any portions of other
    -- entities that they are drawn in front of.
    love.graphics.push'all'
    love.graphics.setCanvas(self.entity_canvas)
    love.graphics.clear()
    love.graphics.setShader()
    love.graphics.setBlendMode'replace'
    love.graphics.applyTransform(self.transform)
    local area = self:get_area()
    local player = self:get_player()

    -- Draw non-player entities.
    for entity in area:each_entity() do
        if entity ~= player then
            love.graphics.draw(entity:get_sprite():get_image(), area:get_entity_position(entity))
        end
    end

    -- Draw the player.
    love.graphics.draw(player:get_sprite():get_image(), area:get_entity_position(player))

    -- Draw indicators above non-player entities.
    for entity in area:each_entity() do
        if entity ~= player then
            local x, y = area:get_entity_position(entity)
            love.graphics.draw(INDICATOR, x + math.floor((Sprite.WIDTH - INDICATOR_WIDTH) / 2), y - INDICATOR_HEIGHT - 1)
        end
    end

    love.graphics.pop()
    love.graphics.draw(self.entity_canvas)
end

function SessionView:press(screen_x, screen_y)
    local entity, offset_x, offset_y =
        self:compute_entity_from_screen_position(screen_x, screen_y)

    if entity == self:get_player() then
        entity:get_sprite():set_pixel(
            offset_x, offset_y,
            self.active_color
        )
    end
end

function SessionView:resize(...)
    Widget.resize(self, ...)
    local width, height = ...
    self.entity_canvas = love.graphics.newCanvas(width, height)
end

function SessionView:tick()
    local player = self:get_player()
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
        self:get_area():move_entity(player, delta_x, delta_y)
    end
end

function SessionView:unbound_key(key, down)
    self.keys_down[key] = down or nil
end

-- #

return SessionView
