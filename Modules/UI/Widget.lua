--[[
    Widget is a mixin that handles common drawing behavior and provides defaults
    for common UI methods.
]]

local Widget = {}

--# Requires

local utf8 = require'utf8'
local is_ctrl_down = require'Helpers'.is_ctrl_down

--# Interface

function Widget:initialize()
    self.geometry = {
        screen_x = 0, screen_y = 0,
        width = 100, height = 100,
    }

    self.bindings = {}
    self.shader = love.graphics.newShader'palette_swap.glsl'
end

function Widget:get_geometry()
    local geometry = self.geometry
    return geometry.screen_x, geometry.screen_y, geometry.width, geometry.height
end

function Widget:set_geometry(new_geometry)
    local geometry = self.geometry

    if new_geometry.screen_x ~= nil then
        geometry.screen_x = new_geometry.screen_x
    end

    if new_geometry.screen_y ~= nil then
        geometry.screen_y = new_geometry.screen_y
    end

    if new_geometry.width ~= nil then
        geometry.width = new_geometry.width
    end

    if new_geometry.height ~= nil then
        geometry.height = new_geometry.height
    end
end

function Widget:on_key(key, down)
    if down then
        local key_combination =
            key:gsub(utf8.charpattern, string.upper, 1)

        if is_ctrl_down() then
            key_combination = 'Ctrl+' .. key_combination
        end

        local binding = self.bindings[key_combination]

        if binding == nil then
            return self:on_unbound_key(key, down)
        else
            return binding(self)
        end
    else
        return self:on_unbound_key(key, down)
    end
end

function Widget:bind(key_combination, handler)
    self.bindings[key_combination] = handler
end

function Widget:set_palette(color0, color1, color2, color3)
    self.shader:sendColor('palette', color0, color1, color2, color3)
end

function Widget:draw()
    local screen_x, screen_y, width, height = self:get_geometry()
    love.graphics.push'all'
    love.graphics.setShader(self.shader)
    self:draw_background()
    self:draw_widget()
    love.graphics.pop()
end

function Widget:draw_background()
    love.graphics.setColor(0, 0, 0, 0)
    love.graphics.rectangle('fill', self:get_geometry())
    love.graphics.setColor(1, 1, 1)
end

-- The remaining methods are explicitly designed to be replaced, but are
-- provided with no-op defaults so that they can reliably be called.

function Widget:draw_widget() end
function Widget:on_scroll(units, ctrl) end
function Widget:on_text_input(text) end
function Widget:on_unbound_key(key, down) end
function Widget:tick() end

return Widget
