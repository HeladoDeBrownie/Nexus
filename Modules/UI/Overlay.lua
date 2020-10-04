local Overlay = {}

--# Requires

local Widget = require'UI/Widget'

--# Methods

function Overlay:initialize(under_widget, over_widget)
    Widget.initialize(self)
    self.under_widget = under_widget
    self.over_widget = over_widget
    self.overlay_active = false
    self.just_switched = false
end

function Overlay:get_active_widget()
    if self.overlay_active then
        return self.over_widget
    else
        return self.under_widget
    end
end

function Overlay:draw(x, y, width, height)
    self.under_widget:draw(x, y, width, height)

    if self.overlay_active then
        self.over_widget:draw(x, y, width, math.floor(height / 3))
    end
end

function Overlay:on_key(...)
    local key, down, ctrl = ...
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
    self.over_widget:tick(...)
    return self.under_widget:tick(...)
end

--# Export

return augment(mix{Widget, Overlay})
