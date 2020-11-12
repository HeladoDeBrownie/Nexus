local Widget = require'UI/Widget'
local is_ctrl_down = require'Helpers'.is_ctrl_down

local Overlay = augment(mix{Widget})

--# Constants

local TICKS_UNTIL_EXTENDED = 16

--# Interface

function Overlay:initialize(under_widget, over_widget)
    Widget.initialize(self)
    self.under_widget = under_widget
    self.over_widget = over_widget
    self.overlay_active = false
    self.just_switched = false
    self.overlay_position = 0 -- fraction out of TICKS_UNTIL_EXTENDED
end

function Overlay:get_active_widget()
    if self.overlay_active then
        return self.over_widget
    else
        return self.under_widget
    end
end

function Overlay:draw()
    local _, height = self:get_dimensions()
    love.graphics.push'all'
    love.graphics.setCanvas(self.canvas)
    self.under_widget:draw()
    love.graphics.draw(self.under_widget:get_canvas())
    self.over_widget:draw()

    love.graphics.draw(self.over_widget:get_canvas(), 0,
        math.floor(
            (-1 + self.overlay_position / TICKS_UNTIL_EXTENDED) *
            height / 3
        ))

    love.graphics.pop()
end

function Overlay:on_key(...)
    local key, down = ...
    local ctrl = is_ctrl_down()
    local active_widget = self:get_active_widget()

    if self.overlay_active then
        if down and not ctrl and key == 'escape' then
            self.overlay_active = false
            self.just_switched = true
        else
            self.just_switched = false
            return active_widget:on_key(...)
        end
    else
        if down and not ctrl and key == '`' then
            self.overlay_active = true
            self.just_switched = true
        else
            self.just_switched = false
            return active_widget:on_key(...)
        end
    end
end

function Overlay:on_press(...)
    return self:get_active_widget():on_press(...)
end

function Overlay:on_scroll(...)
    return self:get_active_widget():on_scroll(...)
end

function Overlay:on_text_input(...)
    if not self.just_switched then
        return self:get_active_widget():on_text_input(...)
    end
end

function Overlay:tick(...)
    local initial_overlay_position = self.overlay_position

    if self.overlay_active then
        self.overlay_position = math.min(
            self.overlay_position + 1,
            TICKS_UNTIL_EXTENDED
        )
    else
        self.overlay_position = math.max(self.overlay_position - 1, 0)
    end

    self.over_widget:tick(...)
    return self.under_widget:tick(...)
end

function Overlay:resize(...)
    Widget.resize(self, ...)
    self.under_widget:resize(...)
    local width, height = ...
    self.over_widget:resize(width, math.floor(height / 3))
end

--#

return Overlay
