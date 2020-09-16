local Serialization = {}

local RETURN_STRING = [[
return {
%s
}
]]

local ITEM_STRING = [[
    %s = %s,]]

-- TODO: stub
function Serialization.serialize_table(a_table)
    local string_table = {}

    for key, value in pairs(a_table) do
        if type(key) == 'string' then
            table.insert(string_table, ITEM_STRING:format(key, value))
        end
    end

    return RETURN_STRING:format(table.concat(string_table, '\n'))
end

return Serialization
