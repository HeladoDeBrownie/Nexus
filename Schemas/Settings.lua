--# Helpers

local is_scale = require'Predicates'.is_integer_in_range(2, 8)

--# Interface

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
