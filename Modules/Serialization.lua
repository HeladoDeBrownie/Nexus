local Serialization = {}

local RETURN_FORMAT = 'return %s'

local TABLE_FORMAT = [[
{
%s
%s}]]

local TABLE_ITEM_FORMAT = '%s%s = %s,'
local INDENT_PREFIX = '    '

local function table_to_lua_code(a_table, depth)
    depth = depth or 0
    local string_table = {}
    local indent = INDENT_PREFIX:rep(depth + 1)

    for key, value in pairs(a_table) do
        local key_type = type(key)
        if key_type == 'string' then
            table.insert(string_table, TABLE_ITEM_FORMAT:format(
                INDENT_PREFIX:rep(depth + 1),
                key,
                Serialization.to_lua_code(value, depth + 1)
            ))
        else
            error(
                ('table_to_lua_code: unsupported key type %s'):format(key_type)
            )
        end
    end

    return TABLE_FORMAT:format(
        table.concat(string_table, '\n'),
        INDENT_PREFIX:rep(depth)
    )
end

function Serialization.to_lua_code(value, depth)
    local the_type = type(value)

    if the_type == 'table' then
        return table_to_lua_code(value, depth)
    else
        return tostring(value)
    end
end

function Serialization.to_lua_module(value)
    return RETURN_FORMAT:format(Serialization.to_lua_code(value, 0))
end

return Serialization