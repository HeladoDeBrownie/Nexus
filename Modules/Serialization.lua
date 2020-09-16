local Serialization = {}

-- TODO: stub
function Serialization.serialize_table(table)
    return [[
return {
    global_scale = 2,
}
]]
end

return Serialization
