local lg = love.graphics
lg.setDefaultFilter('nearest', 'nearest')
local font = require'Font'.new(require'Assets/Font')
local shader = lg.newShader'pixel_shader.glsl'
local buffer = require'TextBuffer'.new()

shader:sendColor('palette',
    {243 / 255, 243 / 255, 243 / 255, 1},
    {  0 / 255, 228 / 255,  54 / 255, 1},
    {  0 / 255, 135 / 255,  81 / 255, 1},
    { 95 / 255,  87 / 255,  79 / 255, 1}
)

lg.setShader(shader)

function love.draw()
    lg.push'all'
    lg.setColor(0, 0, 0, 0)
    lg.rectangle('fill', 0, 0, lg.getDimensions())
    lg.setColor(1, 1, 1)
    lg.scale(8)
    font:print('type here: ' .. buffer:read())
    lg.pop()
end

function love.textinput(text)
    buffer:append(text)
end

function love.keypressed(key)
    if key == 'backspace' then
        buffer:backspace()
    end
end
