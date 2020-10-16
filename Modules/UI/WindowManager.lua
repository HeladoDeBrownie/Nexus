local WindowManager = {}

--# Requires

local Widget = require'UI/Widget'

--# Interface

function WindowManager:initialize(root_widget)
    Widget.initialize(self)
    self.root_widget = root_widget
end

function WindowManager:draw()
    love.graphics.push'all'
    love.graphics.setCanvas(self.canvas)
    self.root_widget:draw()
    love.graphics.draw(self.root_widget:get_canvas())
    love.graphics.pop()
end

function WindowManager:on_key(...)
    Widget.on_key(self, ...)
    self.root_widget:on_key(...)
end

function WindowManager:on_press(...)
    Widget.on_press(self, ...)
    self.root_widget:on_press(...)
end

function WindowManager:on_scroll(...)
    Widget.on_scroll(self, ...)
    self.root_widget:on_scroll(...)
end

function WindowManager:on_text_input(...)
    Widget.on_text_input(self, ...)
    self.root_widget:on_text_input(...)
end

function WindowManager:resize(...)
    Widget.resize(self, ...)
    self.root_widget:resize(...)
end

function WindowManager:tick(...)
    Widget.tick(self, ...)
    self.root_widget:tick(...)
end

--#

return augment(mix{Widget, WindowManager})
