local Color = {}

--# Requires

local is_integer_in_range = require'Predicates'.is_integer_in_range

--# Constants

local HUE_CAP = 360
local SATURATION_MAX = 100
local VALUE_MAX = 100

--# Helpers

local is_hue = is_integer_in_range(0, HUE_CAP - 1)
local is_saturation = is_integer_in_range(0, SATURATION_MAX)
local is_value = is_integer_in_range(0, VALUE_MAX)

--# Interface

function Color:initialize(hue, saturation, value)
    assert(is_hue(hue) and is_saturation(saturation) and is_value(value))
    self.hue = hue
    self.saturation = saturation
    self.value = value
end

function Color:to_normalized_rgba()
    -- TODO
    return 0, 0, 0, 1
end

--#

return augment(Color)
