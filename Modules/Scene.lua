return make_class{
    new = function (self)
        self.x, self.y = 0, 0
    end,

    methods = {
        get_player_position = function (self)
            return self.x, self.y
        end,

        go = function (self, delta_x, delta_y)
            self.x = self.x + delta_x
            self.y = self.y + delta_y
        end,
    },
}
