local private = setmetatable({}, {__mode = 'k'})

local function no_op() end

return function (properties)
    local methods = properties.methods or {}
    local new = properties.new or no_op
    local superclass = properties.superclass
    local class = setmetatable({}, {__index = superclass})
    local member_metatable = {__index = class}

    function class.new(...)
        local self = setmetatable({}, member_metatable)
        local self_ = setmetatable({}, {__index = self})
        private[self] = self_
        new(self_, ...)
        return self
    end

    for method_name, method in pairs(methods) do
        class[method_name] = function (self, ...)
            return method(private[self], ...)
        end
    end

    return class
end
