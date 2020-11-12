local Scene = {}

--# Requires

local Sprite = require'Sprite'

--# Constants

local PLACEHOLDER_CHUNK = love.graphics.newImage'Assets/Placeholder Chunk.png'
local PLACEHOLDER_SPRITE = Sprite.from_file'Assets/Placeholder Sprite.png'
local ENTITY_DOESNT_EXIST_ERROR_FORMAT = "entity doesn't exist: %s"

--# Interface

function Scene:initialize()
    self.entities = {}
    self.next_entity_id = 1
end

function Scene:add_entity(entity_id, sprite, initial_x, initial_y)
    local new_entity_id = entity_id or self:allocate_entity_id()

    self.entities[new_entity_id] = {
        sprite = sprite or PLACEHOLDER_SPRITE,
        x = initial_x,
        y = initial_y,
    }

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

function Scene:get_entity_data(entity_id)
    local sprite = self:get_entity_sprite(entity_id)
    local x, y = self:get_entity_position(entity_id)
    return sprite, x, y
end

function Scene:get_entity_position(entity_id)
    local entity = self.entities[entity_id]
    assert(entity ~= nil, ENTITY_DOESNT_EXIST_ERROR_FORMAT:format(entity_id))
    return entity.x, entity.y
end

function Scene:get_entity_sprite(entity_id)
    return self.entities[entity_id].sprite
end

function Scene:each_entity()
    return pairs(self.entities)
end

function Scene:get_chunk(chunk_x, chunk_y)
    if chunk_x == 0 and chunk_y == 0 then
        return PLACEHOLDER_CHUNK
    end
end

function Scene:move_entity(entity_id, delta_x, delta_y)
    local x, y = self:get_entity_position(entity_id)
    self:place_entity(entity_id, x + delta_x, y + delta_y)
end

function Scene:place_entity(entity_id, x, y)
    local entity = self.entities[entity_id]
    assert(entity ~= nil, ENTITY_DOESNT_EXIST_ERROR_FORMAT:format(entity_id))
    entity.x = x
    entity.y = y
end

function Scene:set_entity_sprite(entity_id, sprite)
    local entity = self.entities[entity_id]
    assert(entity ~= nil, ENTITY_DOESNT_EXIST_ERROR_FORMAT:format(entity_id))
    entity.sprite = sprite
end

function Scene:serialize()
    local data = ''

    for entity_id, entity in self:each_entity() do
        data = data .. ('%s=%s:%s,%s;'):format(
            entity_id,
            entity.sprite:to_byte_string(),
            entity.x, entity.y
        )
    end

    return data
end

function Scene:deserialize(data)
    self.entities = {}

    for entity_id, sprite, x, y in data:gmatch'(.-)=(.-):(.-),(.-);' do
        self:add_entity(entity_id, Sprite.from_byte_string(sprite), x, y)
    end
end

return augment(Scene)
