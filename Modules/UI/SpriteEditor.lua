local SpriteEditor = {}

--# Requires

local Color = require'Color'
local Widget = require'UI/Widget'

--# Constants

local SPRITE_WIDTH = 12
local SPRITE_HEIGHT = 12

--# Helpers

local function color_tuple_from_palette_index(palette_index)
    if palette_index == 0 then
        return 0  , 0  , 0  , 0
    elseif palette_index == 1 then
        return 0  , 0  , 0  , 1
    elseif palette_index == 2 then
        return 0.5, 0.5, 0.5, 1
    elseif palette_index == 3 then
        return 1  , 1  , 1  , 1
    else
        error(('palette index %q out of range'):format(palette_index))
    end
end

--# Interface

function SpriteEditor:initialize(love_image_data, love_image)
    Widget.initialize(self)
    self.active_color = 1
    self.love_image_data = love_image_data
    self.love_image = love_image

    if self.love_image_data == nil then
        self.love_image_data = love.image.newImageData(12, 12)
    end

    if self.love_image == nil then
        self.love_image = love.graphics.newImage(self.love_image_data)
    end

    self:compile_image()

    self:set_palette(
        {Color:new(0, 0,   0):to_normalized_rgba()},
        {Color:new(0, 0,  25):to_normalized_rgba()},
        {Color:new(0, 0,  50):to_normalized_rgba()},
        {Color:new(0, 0, 100):to_normalized_rgba()}
    )

    self:bind('0', SpriteEditor.set_active_color, 0)
    self:bind('1', SpriteEditor.set_active_color, 1)
    self:bind('2', SpriteEditor.set_active_color, 2)
    self:bind('3', SpriteEditor.set_active_color, 3)
end

function SpriteEditor:set_active_color(new_active_color)
    self.active_color = new_active_color
end

function SpriteEditor:compile_image()
    self.love_image:replacePixels(self.love_image_data)
end

function SpriteEditor:draw_widget()
    local width, height = self:get_dimensions()

    for x = 0, SPRITE_WIDTH - 1 do
        for y = 0, SPRITE_HEIGHT - 1 do
            local x_increment = width / SPRITE_WIDTH
            local y_increment = height / SPRITE_HEIGHT
            love.graphics.setColor(self.love_image_data:getPixel(x, y))

            love.graphics.rectangle('fill',
                x * x_increment + 1, y * y_increment + 1,
                x_increment - 2, y_increment - 2
            )
        end
    end
end

function SpriteEditor:on_press(press_x, press_y)
    local width, height = self:get_dimensions()
    local x_increment = width / SPRITE_WIDTH
    local y_increment = height / SPRITE_HEIGHT
    local pixel_x = math.floor(press_x / x_increment)
    local pixel_y = math.floor(press_y / y_increment)

    if 0 <= pixel_x and pixel_x < SPRITE_WIDTH and
       0 <= pixel_y and pixel_y < SPRITE_HEIGHT
    then
        self.love_image_data:setPixel(pixel_x, pixel_y,
            color_tuple_from_palette_index(self.active_color))

        self:compile_image()
    end
end

return augment(mix{Widget, SpriteEditor})
