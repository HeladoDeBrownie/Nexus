local SpriteEditor = {}

--# Requires

local Widget = require'UI/Widget'

--# Constants

local SPRITE_WIDTH = 12
local SPRITE_HEIGHT = 12

local GRAYSCALE_PALETTE = {
    [0] = {0, 0, 0, 0},
    [1] = {0, 0, 0, 1},
    [2] = {0.5, 0.5, 0.5, 1},
    [3] = {1, 1, 1, 1},
}

--# Interface

function SpriteEditor:initialize()
    Widget.initialize(self)
    self.pixels = {}

    for x = 1, SPRITE_WIDTH do
        self.pixels[x] = {}

        for y = 1, SPRITE_HEIGHT do
            self.pixels[x][y] = 2
        end
    end

    self.pixels[6][6] = 3

    self:set_palette(
        {0, 0, 0, 1},
        {0.1, 0.1, 0.1, 1},
        {0.3, 0.3, 0.3, 1},
        {0.6, 0.6, 0.6, 1}
    )
end

function SpriteEditor:draw_widget()
    local x, y, width, height = self:get_geometry()

    for x = 1, SPRITE_WIDTH do
        for y = 1, SPRITE_HEIGHT do
            local x_increment = width / SPRITE_WIDTH
            local y_increment = height / SPRITE_HEIGHT
            love.graphics.setColor(GRAYSCALE_PALETTE[self.pixels[x][y]])

            love.graphics.rectangle('fill',
                (x - 1) * x_increment + 1, (y - 1) * y_increment + 1,
                x_increment - 2, y_increment - 2
            )
        end
    end
end

function SpriteEditor:on_press(x, y)
    print(x, y)
end

return augment(mix{Widget, SpriteEditor})
