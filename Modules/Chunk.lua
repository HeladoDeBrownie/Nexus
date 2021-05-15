local EventSource = require'EventSource'
local Sprite = require'Sprite'

local Chunk = augment(mix{EventSource})

-- # Constants

Chunk.WIDTH, Chunk.HEIGHT = 16, 16
Chunk.PIXEL_WIDTH, Chunk.PIXEL_HEIGHT = Sprite.WIDTH * Chunk.WIDTH, Sprite.HEIGHT * Chunk.HEIGHT

-- # Interface

function Chunk.from_byte_string(byte_string)
    assert(type(byte_string) == 'string', 'byte_string must be a string')
    local result = Chunk:new()
end

function Chunk:initialize()
    EventSource.initialize(self)
    self.tiles = {}

    for tile_x = 0, Chunk.WIDTH - 1 do
        self.tiles[tile_x] = {}

        for tile_y = 0, Chunk.HEIGHT - 1 do
            local tile = Sprite:new()
            tile:set_pixel(0, 0, 1) -- DEBUG
            self.tiles[tile_x][tile_y] = tile

            tile:listen('change', function ()
                self:redraw()
                self:emit('change', tile_x, tile_y, tile)
            end)
        end
    end

    self.image_data = love.image.newImageData(Chunk.PIXEL_WIDTH, Chunk.PIXEL_HEIGHT)
    self.image = love.graphics.newImage(self.image_data)
    self:redraw()
end

function Chunk:get_tile(tile_x, tile_y)
    return self.tiles[tile_x][tile_y]
end

function Chunk:set_tile(tile_x, tile_y, tile)
    self.tiles[tile_x][tile_y] = tile

    sprite:listen('change', function ()
        self:redraw()
        self:emit('change', tile_x, tile_y, tile)
    end)

    self:emit('change', tile_x, tile_y, tile)
    self:redraw()
end

function Chunk:redraw()
    for tile_x = 0, Chunk.WIDTH - 1 do
        for tile_y = 0, Chunk.HEIGHT - 1 do
            self.image_data:paste(
                self.tiles[tile_x][tile_y]:get_image_data(),
                Sprite.WIDTH * tile_x, Sprite.HEIGHT * tile_y,
                0, 0,
                Sprite.WIDTH, Sprite.HEIGHT
            )
        end
    end

    self.image:replacePixels(self.image_data)
end

function Chunk:get_image()
    return self.image
end

-- #

return Chunk
