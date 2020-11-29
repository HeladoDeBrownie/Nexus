local UI = require'UI'

--# Helpers

local is_integer_in_range = require'Predicates'.is_integer_in_range

--# Interface

return {
    UI = {
        Console = {
            scale = {
                type = is_integer_in_range(
                    UI.Console.minimum_scale,
                    UI.Console.maximum_scale
                ),

                default = UI.Console.default_scale,
            },
        },

        SceneView = {
            scale = {
                type = is_integer_in_range(
                    UI.SceneView.minimum_scale,
                    UI.SceneView.maximum_scale
                ),

                default = UI.SceneView.default_scale,
            },
        },
    },
}
