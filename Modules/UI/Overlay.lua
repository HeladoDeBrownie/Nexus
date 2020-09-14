local Overlay = {}
local private = setmetatable({}, {__mode = 'k'})
local overlay_metatable = {__index = Overlay}

function Overlay.new(under_widget, over_widget)
    local result = setmetatable({}, overlay_metatable)

    private[result] = {
        under_widget = under_widget,
        over_widget = over_widget,
        overlay_active = false,
        just_switched = false,
    }

    return result
end

function Overlay:get_active_widget()
    local self_ = private[self]

    if self_.overlay_active then
        return self_.over_widget
    else
        return self_.under_widget
    end
end

function Overlay:on_draw(...)
    return self:get_active_widget():on_draw(...)
end

function Overlay:on_key(...)
    local key, ctrl = ...
    local self_ = private[self]
    local active_widget = self:get_active_widget()

    if self_.overlay_active then
        if not ctrl and key == 'escape' then
            self_.overlay_active = false
            self_.just_switched = true
        else
            self_.just_switched = false
            return active_widget:on_key(...)
        end
    else
        if not ctrl and key == '`' then
            self_.overlay_active = true
            self_.just_switched = true
        else
            self_.just_switched = false
            return active_widget:on_key(...)
        end
    end
end

function Overlay:on_scroll(...)
    return self:get_active_widget():on_scroll(...)
end

function Overlay:on_text_input(...)
    if not private[self].just_switched then
        return self:get_active_widget():on_text_input(...)
    end
end

return Overlay
