return make_class{
    new = function (self)
        self.shader = love.graphics.newShader'palette_swap.glsl'
    end,

    methods = {
        set_palette = function (self, color0, color1, color2, color3)
            self.shader:sendColor('palette',
                color0,
                color1,
                color2,
                color3
            )
        end,

        draw = function (self, x, y, width, height)
            -- Save all draw state for later reversion.
            love.graphics.push'all'

            love.graphics.setShader(self.shader)

            -- Draw the widget's background.
            love.graphics.setColor(0, 0, 0, 0)
            love.graphics.rectangle('fill', x, y, width, height)
            love.graphics.setColor(1, 1, 1)

            -- Run the widget's draw code, which should be overridden for each
            -- specific widget module.
            self:on_draw(x, y, width, height)

            -- Restore the draw state.
            love.graphics.pop()
        end,

        -- methods to be overridden

        on_draw = function (self, x, y, width, height) end,
        on_key = function (self, key, ctrl) end,
        on_scroll = function (self, units, ctrl) end,
        on_text_input = function (self, text) end,
    },
}
