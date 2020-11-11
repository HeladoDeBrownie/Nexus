local Sprite = augment{}

--# Requires

local Predicates = require'Predicates'

--# Constants

local SPRITE_WIDTH, SPRITE_HEIGHT = 12, 12

--# Helpers

local function palette_index_to_rgba(palette_index)
    assert(Predicates.is_integer_in_range(0, 3)(palette_index), "palette index is not 0, 1, 2, or 4")

    if palette_index == 0 then
        return 0  , 0  , 0  , 0
    elseif palette_index == 1 then
        return 0  , 0  , 0  , 1
    elseif palette_index == 2 then
        return 0.5, 0.5, 0.5, 1
    else
        return 1  , 1  , 1  , 1
    end
end

local function rgba_to_palette_index(red, green, blue, alpha)
    if alpha == 0 then
        return 0
    elseif red == 0 and green == 0 and blue == 0 and alpha == 1 then
        return 1
    elseif not (red == 1 and green == 1 and blue == 1 and alpha == 1) then
        return 2
    else
        return 3
    end
end

--# Interface

function Sprite.from_byte_string(byte_string)
    assert(type(byte_string) == 'string', "not a string")
    local result = Sprite:new()
    local byte_index = 1

    for x = 0, SPRITE_WIDTH - 1 do
        for y = 0, SPRITE_HEIGHT - 1 do
            result:set_pixel(x, y,
                tonumber(byte_string:sub(byte_index, byte_index)))

            byte_index = byte_index + 1
        end
    end

    return result
end

function Sprite.from_file(file_name)
    return Sprite.from_image_data(love.image.newImageData(file_name))
end

function Sprite.from_image_data(image_data)
    return Sprite:new(image_data)
end

function Sprite:initialize(source_image_data)
    self.image_data = love.image.newImageData(SPRITE_WIDTH, SPRITE_HEIGHT)

    if source_image_data ~= nil then
        self.image_data:paste(source_image_data, 0, 0)
    end

    self.image = love.graphics.newImage(self.image_data)
end

function Sprite:get_image()
    return self.image
end

function Sprite:get_pixel(x, y)
    return rgba_to_palette_index(self.image_data:getPixel(x, y))
end

function Sprite:set_pixel(x, y, palette_index)
    self.image_data:setPixel(x, y, palette_index_to_rgba(palette_index))
    self.image:replacePixels(self.image_data)
end

function Sprite:to_byte_string()
    local result = ''

    for x = 0, SPRITE_WIDTH - 1 do
        for y = 0, SPRITE_HEIGHT - 1 do
            result = result .. tostring(self:get_pixel(x, y))
        end
    end

    return result
end

function Sprite:to_image_data()
    return self.image_data:clone()
end

--#

return Sprite
