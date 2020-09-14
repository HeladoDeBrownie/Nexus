local lg = love.graphics
local utf8 = require'utf8'

local Font = {}
local private = setmetatable({}, {__mode = 'k'})
local font_metatable = {__index = Font}

function Font.new(metadata)
    local result = setmetatable({}, font_metatable)
    local characters = metadata.characters
    local columns, rows = metadata.columns, metadata.rows
    local glyph_width = metadata.glyph_width
    local glyph_height = metadata.glyph_height
    local image = lg.newImage(metadata.file_name)
    local image_width, image_height = image:getDimensions()
    local quads = {}
    local column, row = 1, 0

    for character in characters:gmatch(utf8.charpattern) do
        quads[character] =
            lg.newQuad(
                column * glyph_width,
                row * glyph_height,
                glyph_width,
                glyph_height,
                image_width,
                image_height
            )

        if column < columns - 1 then
            column = column + 1
        elseif row < rows - 1 then
            column = 0
            row = row + 1
        else
            error'Font.new: inconsistent size specification'
        end
    end

    private[result] = {
        love_image = image,

        love_missing_glyph_quad = lg.newQuad(
            0, 0, glyph_width, glyph_height, image_width, image_height
        ),

        love_quads = quads,
        metadata = metadata,
    }

    return result
end

function Font:print(text)
    local self_ = private[self]
    local x, y = 0, 0

    for character in text:gmatch(utf8.charpattern) do
        if character == '\n' then
            x = 0
            y = y + self_.metadata.glyph_height
        else
            local quad = self_.love_quads[character]

            if quad == nil then
                quad = self_.love_missing_glyph_quad
            end

            lg.draw(self_.love_image, quad, x, y)
            x = x + self_.metadata.glyph_width
        end
    end
end

return Font
