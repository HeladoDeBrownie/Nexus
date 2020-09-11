local function deep_merge(table_a, table_b)
    if type(table_a) == 'table' and type(table_b) == 'table' then
        for key, value in pairs(table_b) do
            if type(value) == 'table' then
                deep_merge(table_a[key], value)
            else
                table_a[key] = value
            end
        end
    else
        error'deep_merge: An attempt was made to merge a non-table.'
    end
end

return deep_merge
