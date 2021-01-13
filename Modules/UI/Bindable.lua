local utf8 = require'utf8'
local is_ctrl_down = require'Helpers'.is_ctrl_down

local Bindable = {}

--# Helpers

local function key_combination_string(key, ctrl_down)
    local result = key:gsub(utf8.charpattern, string.upper, 1)

    if ctrl_down then
        result = 'Ctrl+' .. result
    end

    return result
end

--# Interface

function Bindable:initialize()
    self.bindings = {}
end

-- Create a key binding, used by Bindable.key to handle key combinations.
function Bindable:bind(key_combination, handler, extra_data)
    self.bindings[key_combination] = {
        handler = handler,
        extra_data = extra_data,
    }
end

function Bindable:key(key, down)
    -- When a key combination is pressed, trigger a binding if there is an
    -- appropriate one. Otherwise, call the fallback key handler.
    if down then
        local key_combination = key_combination_string(key, is_ctrl_down())
        local binding = self.bindings[key_combination]

        if binding == nil then
            return self:unbound_key(key, down)
        else
            return binding.handler(self, binding.extra_data)
        end
    else
        return self:unbound_key(key, down)
    end
end

--## Abstract

-- Called when a key combination is not handled by a binding.
function Bindable:unbound_key(key, down) end

--#

return Bindable
