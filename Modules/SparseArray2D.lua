local is_integer = require'Predicates'.is_integer

local SparseArray2D = augment{}

-- # Helpers

local function key_from_ij(i, j)
    assert(is_integer(i) and is_integer(j), 'indices must be integers')
    return ('%s:%s'):format(i, j)
end

local function ij_from_key(key)
    local i, j = key:match'(.+):(.+)'
    return tonumber(i), tonumber(j)
end

-- # Interface

function SparseArray2D:initialize()
    self.store = {}
end

function SparseArray2D:get(i, j)
    return self.store[key_from_ij(i, j)]
end

function SparseArray2D:set(i, j, new_value)
    self.store[key_from_ij(i, j)] = new_value
end

function SparseArray2D:for_each(f)
    for key, value in pairs(self.store) do
        local i, j = ij_from_key(key)
        f(i, j, value)
    end
end

-- #

return SparseArray2D
