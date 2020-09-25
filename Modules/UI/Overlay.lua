return make_class{
    superclass = require'UI/Widget',

    new = function (self, super, under_widget, over_widget)
        super()
        self.under_widget = under_widget
        self.over_widget = over_widget
        self.overlay_active = false
        self.just_switched = false
    end,

    methods = {
        get_active_widget = function (self)
            if self.overlay_active then
                return self.over_widget
            else
                return self.under_widget
            end
        end,

        draw = function (self, x, y, width, height)
            self.under_widget:draw(x, y, width, height)

            if self.overlay_active then
                self.over_widget:draw(x, y, width, math.floor(height / 3))
            end
        end,

        on_key = function (self, ...)
            local key, ctrl = ...
            local active_widget = self:get_active_widget()

            if self.overlay_active then
                if not ctrl and key == 'escape' then
                    self.overlay_active = false
                    self.just_switched = true
                else
                    self.just_switched = false
                    return active_widget:on_key(...)
                end
            else
                if not ctrl and key == '`' then
                    self.overlay_active = true
                    self.just_switched = true
                else
                    self.just_switched = false
                    return active_widget:on_key(...)
                end
            end
        end,

        on_scroll = function (self, ...)
            return self:get_active_widget():on_scroll(...)
        end,

        on_text_input = function (self, ...)
            if not self.just_switched then
                return self:get_active_widget():on_text_input(...)
            end
        end,
    },
}
