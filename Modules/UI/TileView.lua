local lg = love.graphics
local sprite = lg.newImage('Assets/Untitled.png')
local Widget = require'UI/Widget'

local TileView = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local tile_view_metatable = {__index = TileView}

function TileView.new()
    return setmetatable({}, tile_view_metatable)
end

function TileView:on_draw(x, y, width, height)
    self:draw_background(x, y, width, height)
    lg.draw(sprite, x, y)
end

function TileView:on_key(key, ctrl)
end

function TileView:on_scroll(units, ctrl)
end

function TileView:on_text_input(text)
end

return TileView
