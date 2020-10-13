local ColorScheme = {}

--# Requires

local TRANSPARENT = require'Color'.TRANSPARENT

--# Interface

function ColorScheme:initialize(
    background_fill_color,
    background_palette,
    foreground_palette
)
    assert(#background_palette == 3 and #foreground_palette == 3)
    self.background_fill_color = background_fill_color
    self.background_palette = background_palette
    self.foreground_palette = foreground_palette or background_palette
end

function ColorScheme:to_normalized_rgba(background_or_foreground)
    local fill_color
    local palette

    if background_or_foreground == 'background' then
        fill_color = self.background_fill_color
        palette = self.background_palette
    elseif background_or_foreground == 'foreground' then
        fill_color = TRANSPARENT
        palette = self.foreground_palette
    else
        error'Argument must be either "background" or "foreground"'
    end

    return
        {fill_color:to_normalized_rgba()},
        {palette[1]:to_normalized_rgba()},
        {palette[2]:to_normalized_rgba()},
        {palette[3]:to_normalized_rgba()}
end

--#

return augment(ColorScheme)
