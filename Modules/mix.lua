--[[
    This module implements an elementary mixin library with support for private
    fields. An example use might look like the following:

        local mix = require'mix'
        local MyMixin = mix{SomeMixin, SomeOtherMixin, YetAnotherMixin}
        -- [snip]
        local my_object = MyMixin.new("some", "arguments")
    
    Calling mix on zero or more tables creates a new mixin that, in addition to
    having the fields in those tables, has a function field called "new", which
    creates an instance of the combined mixin.

    Whenever two or more of the passed mixins have a field of the same name,
    they are overwritten, favoring the mixins that are presented towards the
    end of the list.

    If there's an "initialize" field in the combined mixin, it's called by "new"
    and passed the new mixin instance as well as any arguments it was given.
    It's the initialize method's responsibility to call any other setup logic it
    needs – this library does not make sure that every mixin's initialize
    method is called, only the one that ends up on the combined mixin. Here is
    a possible idiom for this:

    function MyMixin:initialize(argument_a, argument_b)
        SomeMixin.initialize(self)
        SomeOtherMixin.initialize(self, ":3")
        YetAnotherMixin.initialize(self, argument_a)
        self:do_something_with(argument_b)
    end

    The instance looks up its fields in the combined mixin by default, meaning
    it also has access to the functions that were defined on the individual
    mixins that were passed to mix.

    When a method made available using mix is called on a mixin instance, the
    mixin instance itself is *not* passed to it. Instead, a version of the
    instance but with its private fields available is passed. This means that
    you can still call the instance's methods, but in addition to that, you
    can assign fields directly to it and they will be private, hidden from
    all other code outside of the mixin.
]]

--# Constants

local TYPE_ERROR_FORMAT = 'Mixins must be tables, but mix was passed %q.'

--# State

local private = setmetatable({}, {__mode = 'k'})

--# Export

return function (mixins)
    local combined_mixin = {}

    for _, mixin in ipairs(mixins) do
        -- Only tables can be used as mixins.
        if type(mixin) ~= 'table' then
            error(TYPE_ERROR_FORMAT:format(mixin))
        end

        -- Copy all of the mixin's fields to the combined mixin.
        for field_name, field_value in pairs(mixin) do
            if type(field_value) == 'function' then
                -- Patch functions so that they have private access when able.
                combined_mixin[field_name] = function (self, ...)
                    -- self could be one of three things:
                    -- - a mixin instance
                    -- - a mixin instance's private object
                    -- - an unrelated value
                    -- This or logic ensures these all work correctly.
                    return field_value(private[self] or self, ...)
                end
            else
                -- Do not patch non-functions. This includes callable tables.
                combined_mixin[field_name] = field_value
            end
        end
    end

    function combined_mixin.new(...)
        local object = setmetatable({}, {__index = combined_mixin})
        local private_object = setmetatable({}, {__index = object})

        -- Make the private object available where patched methods can find it.
        private[object] = private_object

        -- This is obtained at instance creation time instead of earlier so that
        -- the combined mixin can be patched with an initialize method after
        -- it's made.
        local initialize = combined_mixin.initialize

        if initialize ~= nil then
            initialize(private_object, ...)
        end

        return object
    end

    return combined_mixin
end
