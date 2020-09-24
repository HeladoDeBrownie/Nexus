local lg = love.graphics
local sprite = lg.newImage'Assets/Untitled.png'
local sprite2 = lg.newImage'Assets/Untitled2.png'
local SceneViewSettings = require'Settings'.UI.SceneView
local Widget = require'UI/Widget'

local SceneView = setmetatable({}, {__index = Widget})
local private = setmetatable({}, {__mode = 'k'})
local scene_view_metatable = {__index = SceneView}

local function rgb24_to_love_color(red, green, blue)
    return red / 255, green / 255, blue / 255, 1
end

function SceneView.new(scene)
    local result = setmetatable(Widget.new(), scene_view_metatable)

    private[result] = {
        scene = scene,
    }

    result:set_palette(
        {rgb24_to_love_color(243, 243, 243)},
        {rgb24_to_love_color(  0, 228,  54)},
        {rgb24_to_love_color(  0, 135,  81)},
        {rgb24_to_love_color( 95,  87,  79)}
    )

    return result
end

function SceneView:on_draw(x, y, width, height)
    local self_ = private[self]

    lg.scale(SceneViewSettings.scale)

    local base_x, base_y = lg.inverseTransformPoint(
        width / 2,
        height / 2
    )

    local player_x, player_y = self_.scene:get_player_position()
    local player_sx, player_sy = x + 12 * player_x, y + 12 * player_y

    lg.translate(
        math.floor(base_x - player_sx - 6),
        math.floor(base_y - player_sy - 6)
    )

    lg.draw(sprite, player_sx, player_sy)
    lg.draw(sprite2, x + 24, y + 36)
end

function SceneView:on_key(key, ctrl)
    local scene = private[self].scene

    if not ctrl then
        if key == 'w' then
            scene:go( 0, -1)
        elseif key == 'a' then
            scene:go(-1,  0)
        elseif key == 's' then
            scene:go( 0,  1)
        elseif key == 'd' then
            scene:go( 1,  0)
        end
    end
end

function SceneView:on_scroll(units, ctrl)
    if ctrl then
        -- Ctrl+Scroll: Zoom in/out
        SceneViewSettings.scale =
            math.max(1, math.min(SceneViewSettings.scale + units, 8))
    end
end

function SceneView:on_text_input(text)
end

return SceneView
