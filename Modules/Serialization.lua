local Serialization = {}

local RETURN_FORMAT = 'return %s'

local TABLE_FORMAT = [[
{
%s
}]]

local TABLE_ITEM_FORMAT = '%s%s = %s'
local INDENT_PREFIX = '    '

local function table_to_lua_code(a_table, depth)
    depth = depth or 0
    local string_table = {}
    local indent = INDENT_PREFIX:rep(depth + 1)

    for key, value in pairs(a_table) do
        if type(key) == 'string' then
            table.insert(string_table,
                TABLE_ITEM_FORMAT:format(indent, key, value)
            )
        end
    end

    return TABLE_FORMAT:format(table.concat(string_table, '\n'))
end

function Serialization.to_lua_code(value)
    local the_type = type(value)
    local data_string

    if the_type == 'table' then
        data_string = table_to_lua_code(value)
    else
        data_string = tostring(value)
    end

    return RETURN_FORMAT:format(data_string)
end

return Serialization
