--[[
    This module implements an elementary mixin library with support for private
    fields.

    See the comments preceding the interface functions for documentation.
]]

local Mixin = {}

--# Constants

local TYPE_ERROR_FORMAT = 'The non-table value %q cannot be mixed.'

--# State

local private = setmetatable({}, {__mode = 'k'})

--# Interface

--[[
    Calling Mixin.mix performs a simple copy of all fields from all the given
    tables into a new, combined table.

    None of the field values are altered in the process. Whenever more than one
    of the tables has the same field name, the table that comes later in the
    list is given precedence.
]]
function Mixin.mix(mixins)
    local final_mixin = {}

    for _, mixin in ipairs(mixins) do
        -- Only tables can be mixed.
        if type(mixin) ~= 'table' then
            error(TYPE_ERROR_FORMAT:format(mixin))
        end

        -- Copy all of the mixin's fields to the combined mixin.
        for field_name, field_value in pairs(mixin) do
            final_mixin[field_name] = field_value
        end
    end

    return final_mixin
end

--[[
    Calling Mixin.new on a table and any number of other arguments creates a
    mixin instance, which is a table looks up its fields in the original table.

    As a special case, whenever the field value is a function that is passed a
    mixin instance as its first argument, it is instead passed that instance's
    private table, thus automatically making any private fields available to
    the function but not to most other code. The private table looks up any
    fields other than those specifically assigned to it in the original mixin
    instance table, thus allowing all methods to still be called from the
    private table.

    After creating the mixin instance and its private table, if the instance has
    an "initialize" field, the field is called as a method, thus allowing any
    required setup specific to the mixin.

    It is not this library's responsibility to call any initialize methods other
    than the one exposed through the passed mixin. In particular, any
    initialize methods from the mixins that it comprises will not be called
    except the one that ends up on the passed mixin.

    Instead, an initialize method can be defined that calls any other necessary
    ones. An example of this idiom:

        function MyMixin:initialize(argument_a, argument_b)
            SomeMixin.initialize(self)
            SomeOtherMixin.initialize(self, ":3")
            YetAnotherMixin.initialize(self, argument_a)
            self:do_something_with(argument_b)
        end
--]]
function Mixin.new(mixin, ...)
    local function index_metamethod(instance, field_name)
        local field_value = rawget(instance, field_name)

        if field_value == nil then
            field_value = mixin[field_name]
        end

        if type(field_value) == 'function' then
            -- Instead of the original function, use a proxy function that
            -- passes the private instance instead. If there isn't a relevant
            -- one, fall back to the actual value passed instead.
            return function (self, ...)
                return field_value(private[self] or self, ...)
            end
        else
            return field_value
        end
    end

    local instance = setmetatable({}, {__index = index_metamethod})

    local private_instance = setmetatable({_public = instance},
        {__index = instance})

    -- Make the private instance available where proxy methods can find it.
    private[instance] = private_instance

    if instance.initialize ~= nil then
        instance:initialize(...)
    end

    return instance
end

--[[
    Calling Mixin.augment on a table adds a "new" field to it that can be
    called as a method for the same effect as passing the table to Mixin.new.

    See Mixin.new for details.
--]]
function Mixin.augment(mixin)
    mixin.new = Mixin.new
    return mixin
end

--# Export

return Mixin
