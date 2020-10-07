local SpriteEditor = {}

--# Requires

local Widget = require'UI/Widget'

--# Constants

local SPRITE_WIDTH = 12
local SPRITE_HEIGHT = 12

--# Interface

function SpriteEditor:initialize()
    Widget.initialize(self)
    self.pixels = {}

    for x = 1, SPRITE_WIDTH do
        self.pixels[x] = {}

        for y = 1, SPRITE_HEIGHT do
            self.pixels[x][y] = 0
        end
    end
end

function SpriteEditor:draw_widget(x, y, width, height)
    print'TODO'
end

return augment(mix{Widget, SpriteEditor})
