local Font = {}

--# Requires

local utf8 = require'utf8'

--# Constants

local MISSING_GLYPH = '\0'

--# Methods

function Font:initialize(metadata)
    local image = love.graphics.newImage(metadata.file_name)
    local quads = {}

    for row_index, row_characters in ipairs(metadata.characters) do
        local column_index = 1

        for character in row_characters:gmatch(utf8.charpattern) do
            quads[character] = love.graphics.newQuad(
                (column_index - 1) * metadata.glyph_width,
                (row_index - 1) * metadata.glyph_height,
                metadata.glyph_width,
                metadata.glyph_height,
                image:getDimensions()
            )

            column_index = column_index + 1
        end
    end

    self.love_image = image
    self.love_quads = quads
    self.metadata = metadata
end

function Font:print(text)
    local x, y = 0, 0

    for character in text:gmatch(utf8.charpattern) do
        if character == '\n' then
            x = 0
            y = y + self.metadata.glyph_height
        else
            local quad = self.love_quads[character]

            if quad == nil then
                quad = self.love_quads[MISSING_GLYPH]
            end

            love.graphics.draw(self.love_image, quad, x, y)
            x = x + self.metadata.glyph_width
        end
    end
end

function Font:compute_height(text, width)
    -- TODO: Take width and line wrapping into account.
    local number_of_rows = 1

    for _ in text:gmatch'[^\n]*\n' do
        number_of_rows = number_of_rows + 1
    end

    return number_of_rows * self.metadata.glyph_height
end

--# Export

return mix{Font}
