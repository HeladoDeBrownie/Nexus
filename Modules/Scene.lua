local Scene = {}

--# Methods

function Scene:initialize()
    self.x, self.y = 0, 0
end

function Scene:tick()
    print'tick!'
end

function Scene:get_player_position()
    return self.x, self.y
end

function Scene:go(delta_x, delta_y)
    self.x = self.x + delta_x
    self.y = self.y + delta_y
end

--# Export

return mix{Scene}
