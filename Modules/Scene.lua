local Scene = {}

--# Constants

-- STUB
local chunk = love.graphics.newImage'Assets/Test Chunk.png'

--# Methods

function Scene:initialize()
    self.x, self.y = 0, 0
end

function Scene:tick()
    --print'tick!'
end

function Scene:get_player_position()
    return self.x, self.y
end

-- STUB
function Scene:get_chunk(chunk_x, chunk_y)
    if chunk_x == 0 and chunk_y == 0 then
        return chunk
    end
end

function Scene:go(delta_x, delta_y)
    self.x = self.x + delta_x
    self.y = self.y + delta_y
end

--# Export

return augment(Scene)
