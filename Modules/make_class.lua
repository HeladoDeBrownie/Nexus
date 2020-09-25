local private = setmetatable({}, {__mode = 'k'})

local function no_op() end

return function (properties)
    local methods = properties.methods or {}
    local new = properties.new or no_op
    local superclass = properties.superclass
    local class = setmetatable({}, {__index = superclass})
    local member_metatable = {__index = class}
    private[class] = properties

    function class.new(...)
        local self, self_

        self = setmetatable({}, member_metatable)
        self_ = setmetatable({}, {__index = self})
        private[self] = self_

        local function super(...)
            private[superclass].new(self_, ...)
        end

        if superclass == nil then
            new(self_, ...)
        else
            new(self_, super, ...)
        end

        return self
    end

    for method_name, method in pairs(methods) do
        class[method_name] = function (self, ...)
            return method(private[self] or self, ...)
        end
    end

    return class
end
