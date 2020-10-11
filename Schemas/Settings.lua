local function is_integer(value)
    return type(value) == 'number' and value == math.floor(value)
end

local function is_integer_between(low, high)
    return function (value)
        return is_integer(value) and value >= low and value <= high
    end
end

local is_scale = is_integer_between(2, 8)

return {
    UI = {
        Console = {
            scale = {type = is_scale, default = 2},
        },

        SceneView = {
            scale = {type = is_scale, default = 4},
        },
    },
}
