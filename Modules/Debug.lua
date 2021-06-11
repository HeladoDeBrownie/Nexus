local Debug = {}

function Debug.print_keys(a_table)
    for key, _ in pairs(a_table) do
        print(key)
    end
end

return Debug
