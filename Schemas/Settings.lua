--# Helpers

local is_integer_in_range = require'Predicates'.is_integer_in_range

--# Interface

return {
    UI = {
        Console = {
            scale = {type = is_integer_in_range(2, 8), default = 2},
        },

        SceneView = {
            scale = {type = is_integer_in_range(4, 16), default = 8},
        },
    },
}
