local Chunk = require'Chunk'
local SparseArray2D = require'SparseArray2D'

local Area = augment{}

-- # Interface

function Area:initialize()
    self.color_scheme = nil
    self.chunk_array = SparseArray2D:new()
end

function Area:get_color_scheme()
    return self.color_scheme
end

function Area:set_color_scheme(new_color_scheme)
    self.color_scheme = new_color_scheme
end

function Area:get_chunk(chunk_x, chunk_y)
    local chunk = self.chunk_array:get(chunk_x, chunk_y)

    if chunk == nil then
        return self:load_chunk(chunk_x, chunk_y)
    else
        return chunk
    end
end

function Area:set_chunk(chunk_x, chunk_y, chunk)
    self.chunk_array:set(chunk_x, chunk_y, chunk)
end

function Area:load_chunk(chunk_x, chunk_y)
    -- TODO: deserialize the chunk instead of creating a whole new one
    local chunk = Chunk:new()
    self.chunk_array:set(chunk_x, chunk_y, chunk)
    return chunk
end

function Area:unload_chunk(chunk_x, chunk_y)
    local chunk = self.chunk_array:get(chunk_x, chunk_y)

    if chunk:is_modified() then
        -- TODO: serialize the chunk
        self.chunk_array:set(chunk_x, chunk_y, nil)
    end
end

-- #

return Area
