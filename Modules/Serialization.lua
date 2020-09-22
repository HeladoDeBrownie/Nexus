local Serialization = {}

--# Constants

local MODULE_FORMAT = [[
-- This is an automatically generated Lua module. Take care when editing it.
return %s
]]

local TABLE_FORMAT = [[
{
%s
%s}]]

local TABLE_ITEM_FORMAT = '%s%s = %s,'
local INDENT_PREFIX = '    '
local KEY_TYPE_ERROR = 'unsupported key type %q'
local SCHEMA_ERROR = 'the value %q does not match the expected type %q, and the schema does not specify a default value for it'

--# Helpers

local function table_to_lua_code(a_table, depth)
    depth = depth or 0
    local string_table = {}
    local indent = INDENT_PREFIX:rep(depth + 1)

    for key, value in pairs(a_table) do
        local key_type = type(key)
        if key_type == 'string' then
            table.insert(string_table, TABLE_ITEM_FORMAT:format(
                INDENT_PREFIX:rep(depth + 1),
                key,
                Serialization.to_lua_code(value, depth + 1)
            ))
        else
            error(KEY_TYPE_ERROR:format(key_type))
        end
    end

    return TABLE_FORMAT:format(
        table.concat(string_table, '\n'),
        INDENT_PREFIX:rep(depth)
    )
end

--# Interface

function Serialization.apply_schema(value, schema)
    if type(schema) == 'table' then
        if schema.type == nil then
            -- We are dealing with a table structure.

            if type(value) ~= 'table' then
                value = {}
            end

            for key, sub_schema in pairs(schema) do
                value[key] = Serialization.apply_schema(value[key], sub_schema)
            end

            return value
        else
            -- We are dealing with a terminal element.

            if type(schema.type) == 'function' and schema.type(value) then
                return value
            elseif type(value) == schema.type then
                return value
            elseif schema.default == nil then
                error(SCHEMA_ERROR:format(value, schema.type))
            else
                return schema.default
            end
        end
    else
        return schema
    end
end

function Serialization.safe_require(module_name, schema)
    local succeeded, module = pcall(require, module_name)

    if not succeeded then
        module = nil
    end

    module = Serialization.apply_schema(module, schema)
    package.loaded[module_name] = module
    return module
end

function Serialization.to_lua_code(value, depth)
    local the_type = type(value)

    if the_type == 'table' then
        return table_to_lua_code(value, depth)
    elseif the_type == 'string' then
        return ('%q'):format(value)
    else
        return tostring(value)
    end
end

function Serialization.to_lua_module(value)
    return MODULE_FORMAT:format(Serialization.to_lua_code(value, 0))
end

--# Export

return Serialization
