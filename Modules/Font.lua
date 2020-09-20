local lg = love.graphics
local utf8 = require'utf8'

local Font = {}
local private = setmetatable({}, {__mode = 'k'})
local font_metatable = {__index = Font}
local MISSING_GLYPH = '\0'

function Font.new(metadata)
    local self = setmetatable({}, font_metatable)
    local image = lg.newImage(metadata.file_name)
    local quads = {}

    for row_index, row_characters in ipairs(metadata.characters) do
        local column_index = 1

        for character in row_characters:gmatch(utf8.charpattern) do
            quads[character] = lg.newQuad(
                (column_index - 1) * metadata.glyph_width,
                (row_index - 1) * metadata.glyph_height,
                metadata.glyph_width,
                metadata.glyph_height,
                image:getDimensions()
            )

            column_index = column_index + 1
        end
    end

    private[self] = {
        love_image = image,
        love_quads = quads,
        metadata = metadata,
    }

    return self
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
                quad = self_.love_quads[MISSING_GLYPH]
            end

            lg.draw(self_.love_image, quad, x, y)
            x = x + self_.metadata.glyph_width
        end
    end
end

function Font:compute_height(text, width)
    -- TODO: Take width and line wrapping into account.
    local number_of_rows = 1

    for _ in text:gmatch'[^\n]*\n' do
        number_of_rows = number_of_rows + 1
    end

    return number_of_rows * private[self].metadata.glyph_height
end

return Font
