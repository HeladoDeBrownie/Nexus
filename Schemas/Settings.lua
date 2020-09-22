local function is_integer(value)
    return type(value) == 'number' and value == math.floor(value)
end

return {
    UI = {
        global_scale = {type = is_integer, default = 2},

        Console = {
            scale = {type = is_integer, default = 1},
        },

        TileView = {
            scale = {type = is_integer, default = 2},
        },
    },
}
