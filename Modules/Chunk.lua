local Sprite = require'Sprite'

local Chunk = augment{}

-- # Constants

Chunk.WIDTH, Chunk.HEIGHT = 16, 16
Chunk.PIXEL_WIDTH, Chunk.PIXEL_HEIGHT = Sprite.WIDTH * Chunk.WIDTH, Sprite.HEIGHT * Chunk.HEIGHT

-- # Interface

function Chunk.from_byte_string(byte_string)
    assert(type(byte_string) == 'string', 'byte_string must be a string')
    local result = Chunk:new()
end

function Chunk:initialize()
    self.modified = false
    self.tiles = {}

    for tile_x = 0, Chunk.WIDTH - 1 do
        self.tiles[tile_x] = {}

        for tile_y = 0, Chunk.HEIGHT - 1 do
            local tile = Sprite:new()
            tile:set_pixel(0, 0, 1) -- DEBUG
            self.tiles[tile_x][tile_y] = tile
        end
    end

    self.image_data = love.image.newImageData(Chunk.PIXEL_WIDTH, Chunk.PIXEL_HEIGHT)
    self.image = love.graphics.newImage(self.image_data)
    self:redraw()
end

function Chunk:is_modified()
    return self.modified
end

function Chunk:clear_modified()
    self.modified = false
end

function Chunk:with_tile(tile_x, tile_y, f)
    local tile = self.tiles[tile_x][tile_y]
    f(tile)
    
    if tile:is_modified() then
        self.modified = true
        self:redraw()
    end
end

function Chunk:set(tile_x, tile_y, sprite)
    self.tiles[tile_x][tile_y] = sprite
    self.modified = true
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
