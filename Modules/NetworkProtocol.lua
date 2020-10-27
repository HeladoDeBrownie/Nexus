local NetworkProtocol = {}

--# Helpers

--## Renderers

local function render_welcome_message(slot_id)
    return ('WELCOME %s'):format(slot_id)
end

local function render_place_message(x, y)
    return ('PLACE %d %d'):format(x, y)
end

--## Parsers

local function parse_welcome_message(message)
    local slot_id = message:match'^WELCOME (.*)$'

    if slot_id ~= nil then
        return {
            type = 'welcome',
            slot_id = slot_id,
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

--# Interface

function NetworkProtocol.render_message(message_table)
    local origin_prefix = ''

    if message_table.origin ~= nil then
        origin_prefix = ('[%s]'):format(tostring(message_table.origin))
    end

    if message_table.type == 'welcome' then
        local slot_id = message_table.slot_id
        return origin_prefix .. render_welcome_message(slot_id)
    elseif message_table.type == 'place' then
        local x, y = message_table.x, message_table.y
        return origin_prefix .. render_place_message(x, y)
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
        parse_welcome_message(message) or
        parse_place_message(message)

    if message_table == nil then
        error(('could not parse message %q'):format(raw_message))
    else
        message_table.origin = origin
        return message_table
    end
end

--#

return NetworkProtocol
