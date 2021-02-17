local Container = require'UI/Container'
local is_ctrl_down = require'Helpers'.is_ctrl_down

local Overlay = augment(mix{Container})

--# Constants

local TICKS_UNTIL_EXTENDED = 16

--# Helpers

local function update_over_widget(self)
    local _, height = self.over_widget:get_dimensions()

    self:place_widget(self.over_widget, 0,
        math.floor((-1 + self.overlay_position / TICKS_UNTIL_EXTENDED) * height)
    )
end

--# Interface

function Overlay:initialize(root_widget, over_widget)
    Container.initialize(self, root_widget)
    self.over_widget = over_widget
    self.just_switched = false
    self.overlay_position = 0 -- fraction out of TICKS_UNTIL_EXTENDED
    self:add_widget(over_widget, 0, 0, over_widget:get_dimensions())
    update_over_widget(self)
end

function Overlay:key(...)
    local key, down = ...
    local ctrl = is_ctrl_down()
    local active_widget = self:get_active_widget()

    if active_widget == self.root_widget and down and not ctrl and key == '`' then
        self:set_active_widget(self.over_widget)
        self.just_switched = true
    elseif active_widget ~= self.root_widget and down and not ctrl and key == 'escape' then
        self:set_active_widget(nil)
        self.just_switched = true
    else
        self.just_switched = false
        return Container.key(self, ...)
    end
end

function Overlay:text_input(...)
    if not self.just_switched then
        Container.text_input(self, ...)
    end
end

function Overlay:tick(...)
    local initial_overlay_position = self.overlay_position

    if self:get_active_widget() == self.over_widget then
        self.overlay_position = math.min(
            self.overlay_position + 1,
            TICKS_UNTIL_EXTENDED
        )
    else
        self.overlay_position = math.max(self.overlay_position - 1, 0)
    end

    update_over_widget(self)
    return Container.tick(self, ...)
end

function Overlay:resize(...)
    local width, height = ...
    self:resize_widget(self.over_widget, width, math.floor(height / 3))
    return Container.resize(self, ...)
end

--#

return Overlay
