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
    -- Algorithm source: https://en.wikipedia.org/wiki/HSL_and_HSV#HSV_to_RGB

    local normalized_value = self.value / VALUE_MAX
    local normalized_saturation = self.saturation / SATURATION_MAX
    local chroma = normalized_value * normalized_saturation
    local hue_ = self.hue / (HUE_CAP / 6)
    local x = chroma * (1 - math.abs(hue_ % 2 - 1))
    local r_, g_, b_

    if 0 <= hue_ and hue_ <= 1 then
        r_, g_, b_ = chroma, x, 0
    elseif 1 < hue_ and hue_ <= 2 then
        r_, g_, b_ = x, chroma, 0
    elseif 2 < hue_ and hue_ <= 3 then
        r_, g_, b_ = 0, chroma, x
    elseif 3 < hue_ and hue_ <= 4 then
        r_, g_, b_ = 0, x, chroma
    elseif 4 < hue_ and hue_ <= 5 then
        r_, g_, b_ = x, 0, chroma
    elseif 5 < hue_ and hue_ <= 6 then
        r_, g_, b_ = chroma, 0, hue
    else
        r_, g_, b_ = 0, 0, 0
    end

    local base = normalized_value - chroma
    return r_ + base, g_ + base, b_ + base, 1
end

--#

return augment(Color)
