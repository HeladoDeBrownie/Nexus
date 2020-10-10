local Overlay = {}

--# Requires

local Widget = require'UI/Widget'
local is_ctrl_down = require'Helpers'.is_ctrl_down

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
    self.under_widget:draw()
    self.over_widget:draw()
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

    if self.overlay_position ~= initial_overlay_position then
        self:set_geometry{}
    end

    self.over_widget:tick(...)
    return self.under_widget:tick(...)
end

function Overlay:set_geometry(...)
    Widget.set_geometry(self, ...)
    self.under_widget:set_geometry(...)
    local screen_x, screen_y, width, height = self:get_geometry()

    self.over_widget:set_geometry{
        screen_x = screen_x,
        screen_y = screen_y,
        width = width,
        height = math.floor(
            self.overlay_position * height / (3 * TICKS_UNTIL_EXTENDED)
        ),
    }
end

return augment(mix{Widget, Overlay})
