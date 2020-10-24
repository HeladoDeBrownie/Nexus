local NetworkProtocol = {}

--# Helpers

local function render_place_message(x, y)
    return ('PLACE %d %d'):format(x, y)
end

local function parse_place_message(message)
    local x, y = message:match'^PLACE (%d+) (%d+)$'

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

    if message_table.type == 'place' then
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

    local message_table = parse_place_message(message)

    if message_table == nil then
        error(('could not parse message %q'):format(raw_message))
    else
        message_table.origin = origin
        return message_table
    end
end

--#

return NetworkProtocol
