local Scene = {}

--# Constants

local chunk = love.graphics.newImage'Assets/Test Chunk.png'

--# Interface

function Scene:initialize()
    self.entities = {}
    self.next_entity_id = 1
end

function Scene:add_entity(initial_x, initial_y, entity_id)
    local new_entity_id = entity_id or self:allocate_entity_id()
    self.entities[new_entity_id] = {x = initial_x, y = initial_y}
    return new_entity_id
end

function Scene:remove_entity(entity_id)
    self.entities[entity_id] = nil
end

function Scene:allocate_entity_id()
    local entity_id = self.next_entity_id
    self.next_entity_id = self.next_entity_id + 1
    return entity_id
end

function Scene:get_entity_position(entity_id)
    local entity = self.entities[entity_id]

    if entity ~= nil then
        return entity.x, entity.y
    end
end

function Scene:each_entity()
    return pairs(self.entities)
end

function Scene:get_chunk(chunk_x, chunk_y)
    if chunk_x == 0 and chunk_y == 0 then
        return chunk
    end
end

function Scene:move_entity(entity_id, delta_x, delta_y)
    local x, y = self:get_entity_position(entity_id)
    self:place_entity(entity_id, x + delta_x, y + delta_y)
end

function Scene:place_entity(entity_id, x, y)
    local entity = self.entities[entity_id]

    if entiy == nil then
        self:add_entity(x, y, entity_id)
    else
        entity.x = x
        entity.y = y
    end
end

return augment(Scene)
