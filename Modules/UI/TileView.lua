local lg = love.graphics
local sprite = lg.newImage('Assets/Untitled.png')

local TileView = {}
local private = setmetatable({}, {__mode = 'k'})
local tile_view_metatable = {__index = TileView}

function TileView.new()
    return setmetatable({}, tile_view_metatable)
end

function TileView:on_draw(x, y, width, height)
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', x, y, width, height)
    lg.setColor(1, 1, 1)
    lg.draw(sprite, x, y)
end

function TileView:on_key(key, ctrl)
end

function TileView:on_scroll(units, ctrl)
end

function TileView:on_text_input(text)
end

return TileView
