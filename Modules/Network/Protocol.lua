local NetworkProtocol = {}

--# Helpers

--## Renderers

local function render_hello_message(sprite_byte_string)
    return ('HELLO %s'):format(sprite_byte_string)
end

local function render_welcome_message(origin)
    return ('WELCOME %s'):format(origin)
end

local function render_place_message(x, y)
    return ('PLACE %d %d'):format(x, y)
end

local function render_scene_message(data)
    return ('SCENE %s'):format(data)
end

local function render_sprite_message(sprite_byte_string)
    return ('SPRITE %s'):format(sprite_byte_string)
end

--## Parsers

local function parse_hello_message(message)
    local sprite_byte_string = message:match'^HELLO (.*)$'

    if sprite_byte_string ~= nil then
        return {
            type = 'hello',
            sprite_byte_string = sprite_byte_string,
        }
    end
end

local function parse_welcome_message(message)
    local origin = message:match'^WELCOME (.*)$'

    if origin ~= nil then
        return {
            type = 'welcome',
            origin = origin,
        }
    end
end

local function parse_place_message(message)
    local x, y = message:match'^PLACE (-?%d+) (-?%d+)$'

    if x ~= nil then
        return {
            type = 'place',
            x = x,
            y = y,
        }
    end
end

local function parse_scene_message(message)
    local scene_data = message:match'^SCENE (.*)$'

    if scene_data ~= nil then
        return {
            type = 'scene',
            data = scene_data,
        }
    end
end

local function parse_sprite_message(message)
    local sprite_byte_string = message:match'^SPRITE (.*)$'

    if sprite_byte_string ~= nil then
        return {
            type = 'sprite',
            sprite_byte_string = sprite_byte_string,
        }
    end
end

--# Interface

function NetworkProtocol.render_message(message_table)
    local origin_prefix = ''

    if message_table.origin ~= nil then
        origin_prefix = ('[%s]'):format(tostring(message_table.origin))
    end

    if message_table.type == 'hello' then
        local sprite_byte_string = message_table.sprite_byte_string
        return origin_prefix .. render_hello_message(sprite_byte_string)
    elseif message_table.type == 'welcome' then
        local origin = message_table.origin
        return origin_prefix .. render_welcome_message(origin)
    elseif message_table.type == 'place' then
        local x, y = message_table.x, message_table.y
        return origin_prefix .. render_place_message(x, y)
    elseif message_table.type == 'scene' then
        local data = message_table.data
        return origin_prefix .. render_scene_message(data)
    elseif message_table.type == 'sprite' then
        local sprite_byte_string = message_table.sprite_byte_string
        return origin_prefix .. render_sprite_message(sprite_byte_string)
    else
        error(('could not render message of type %q'):format(tostring(message_table.type)))
    end
end

function NetworkProtocol.parse_message(raw_message)
    local origin, message = raw_message:match'^%[([^]]*)](.*)$'

    if origin == nil then
        message = raw_message
    end

    local message_table =
        parse_hello_message(message) or
        parse_welcome_message(message) or
        parse_place_message(message) or
        parse_scene_message(message) or
        parse_sprite_message(message)

    if message_table == nil then
        error(('could not parse message %q'):format(raw_message))
    else
        message_table.origin = origin
        return message_table
    end
end

--#

return NetworkProtocol
