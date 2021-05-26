local EventSource = require'EventSource'
local Sprite = require'Sprite'

local Entity = augment(mix{EventSource})

-- # Interface

function Entity:initialize(sprite)
    EventSource.initialize(self)

    if sprite == nil then
        self.sprite = Sprite:new()
    else
        self.sprite = sprite
    end
end

function Entity:get_sprite()
    return self.sprite
end

function Entity:set_sprite(new_sprite)
    self.sprite = new_sprite
end

-- #

return Entity
