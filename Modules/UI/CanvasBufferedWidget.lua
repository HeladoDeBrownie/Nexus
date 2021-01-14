--[[
    CanvasBufferedWidget is a *mostly* drop-in replacement for Widget that
    differs from Widget in that painting is buffered to a canvas before the
    screen.
    
    This allows, e.g., complex drawing logic to be done less often than once
    per frame in cases where there isn't always something to update every frame.
--]]

local Widget = require'UI/Widget'

local CanvasBufferedWidget = mix{Widget}

-- # Interface

function CanvasBufferedWidget:initialize(...)
    Widget.initialize(self, ...)
    self.canvas = love.graphics.newCanvas()
end

function CanvasBufferedWidget:resize(...)
    local width, height = ...

    -- Canvas dimensions cannot be changed after they're created, so instead
    -- discard the old canvas and create a new one of the correct size.
    self.canvas = love.graphics.newCanvas(width, height)

    return Widget.resize(self, ...)
end

function CanvasBufferedWidget:draw(x, y)
    -- TODO: This refresh call is temporary until widgets are changed to refresh
    -- themselves at appropriate times.
    self:refresh()

    love.graphics.draw(self.canvas, x, y)
end

function CanvasBufferedWidget:refresh()
    love.graphics.push'all'
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()
    self:paint()
    love.graphics.pop()
end

-- #

return CanvasBufferedWidget
