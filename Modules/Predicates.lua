local Predicates = {}

--# Interface

function Predicates.is_in_range(low, high)
    return function (value)
        return low <= value and value <= high
    end
end

function Predicates.is_integer(value)
    return Predicates.is_number(value) and value == math.floor(value)
end

function Predicates.is_integer_in_range(low, high)
    return function (value)
        return Predicates.is_integer(value) and value >= low and value <= high
    end
end

function Predicates.is_number(value)
    return type(value) == 'number'
end

--#

return Predicates
