local TileView = {}
local private = setmetatable({}, {__mode = 'k'})
local tile_view_metatable = {__index = TileView}

function TileView.new()
    return setmetatable({}, tile_view_metatable)
end

function TileView:on_draw(x, y, width, height)
end

function TileView:on_key(key, ctrl)
end

function TileView:on_scroll(units, ctrl)
end

function TileView:on_text_input(text)
end

return TileView
