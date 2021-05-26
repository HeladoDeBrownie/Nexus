local Chunk = require'Chunk'
local EventSource = require'EventSource'
local SparseArray2D = require'SparseArray2D'
local is_integer = require'Predicates'.is_integer

local Area = augment(mix{EventSource})

-- # Interface

function Area:initialize(color_scheme)
    EventSource.initialize(self)

    if color_scheme ~= nil then
        self:set_color_scheme(color_scheme)
    end

    self.chunk_array = SparseArray2D:new()
    self.entity_positions = {}
end

function Area:get_color_scheme()
    return self.color_scheme
end

function Area:set_color_scheme(new_color_scheme)
    self.color_scheme = new_color_scheme
end

function Area:get_chunk(chunk_x, chunk_y)
    return self.chunk_array:get(chunk_x, chunk_y)
end

function Area:set_chunk(chunk_x, chunk_y, chunk)
    self.chunk_array:set(chunk_x, chunk_y, chunk)
end

function Area:has_entity(entity)
    assert(entity ~= nil, 'entity must not be nil')
    return self.entity_positions[entity] ~= nil
end

function Area:get_entity_position(entity)
    assert(self:has_entity(entity), 'entity must be in area')
    local position = self.entity_positions[entity]
    return position.x, position.y
end

function Area:each_entity()
    return function (_, entity)
        return next(self.entity_positions, entity)
    end
end

function Area:add_entity(entity, x, y)
    assert(not self:has_entity(entity), 'entity must not already be in area')
    assert(is_integer(x) and is_integer(y), 'coordinates must be integers')
    self.entity_positions[entity] = {x = x, y = y}
end

function Area:remove_entity(entity)
    assert(self:has_entity(entity), 'entity must be in area')
    self.entity_positions[entity] = nil
end

function Area:place_entity(entity, x, y)
    assert(self:has_entity(entity), 'entity must be in area')
    assert(is_integer(x) and is_integer(y), 'coordinates must be integers')
    local position = self.entity_positions[entity]
    position.x, position.y = x, y
end

function Area:move_entity(entity, delta_x, delta_y)
    local x, y = self:get_entity_position(entity)
    self:place_entity(entity, x + delta_x, y + delta_y)
end

-- #

return Area
