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

        SessionView = {
            scale = {
                type = is_integer_in_range(
                    UI.SessionView.minimum_scale,
                    UI.SessionView.maximum_scale
                ),

                default = UI.SessionView.default_scale,
            },
        },
    },
}
