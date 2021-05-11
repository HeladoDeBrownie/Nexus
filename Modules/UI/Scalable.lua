local is_ctrl_down = require'Helpers'.is_ctrl_down

local Scalable = {}

--# Constants

Scalable.minimum_scale = 4
Scalable.maximum_scale = 16

--# Interface

function Scalable:initialize(settings, minimum_scale, maximum_scale)
    self.minimum_scale = minimum_scale
    self.maximum_scale = maximum_scale
    self.settings = settings
    self:set_scale(settings.scale)
end

function Scalable:get_scale()
    return self.settings.scale
end

function Scalable:set_scale(new_scale)
    self.settings.scale = math.max(
        self.minimum_scale,
        math.min(math.floor(new_scale), self.maximum_scale)
    )
end

function Scalable:adjust_scale(scale_delta)
    self:set_scale(self:get_scale() + scale_delta)
end

function Scalable:apply_scale()
    love.graphics.scale(self.settings.scale)
end

function Scalable:scroll(units)
    if is_ctrl_down() then
        -- Ctrl+Scroll: Zoom in/out
        self:adjust_scale(units)
    end
end

return Scalable
