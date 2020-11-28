local Sprite = require'Sprite'

local Chunk = augment{}

-- # Constants

Chunk.WIDTH, Chunk.HEIGHT = 16, 16

-- # Helpers

local function redraw_canvas(chunk)
    love.graphics.push'all'
    love.graphics.setCanvas(chunk.canvas)

    for tile_x = 1, Chunk.WIDTH do
        for tile_y = 1, Chunk.HEIGHT do
            love.graphics.draw(
                chunk.tiles[tile_x][tile_y]:get_image(),
                Sprite.WIDTH * tile_x, Sprite.HEIGHT * tile_y
            )
        end
    end

    love.graphics.pop()
end

-- # Interface

function Chunk.from_byte_string(byte_string)
    assert(type(byte_string) == 'string', 'byte_string must be a string')
    local result = Chunk:new()
end

function Chunk:initialize()
    self.modified = false
    self.tiles = {}

    for tile_x = 1, Chunk.WIDTH do
        self.tiles[tile_x] = {}

        for tile_y = 1, Chunk.HEIGHT do
            self.tiles[tile_x][tile_y] = Sprite:new()
        end
    end

    self.canvas = love.graphics.newCanvas(Chunk.WIDTH * Sprite.WIDTH, Chunk.HEIGHT * Sprite.HEIGHT)
    redraw_canvas(self)
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
        redraw_canvas(self)
    end
end

function Chunk:set(tile_x, tile_y, sprite)
    self.tiles[tile_x][tile_y] = sprite
    self.modified = true
    redraw_canvas(self)
end

function Chunk:get_drawable()
    return self.canvas
end

-- #

return Chunk
