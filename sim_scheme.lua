--=======================================================================
-- File Name    : sim_scheme.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Mon Nov 23 14:04:11 2015
-- Description  : a syntactic sugar to simulate scheme
-- Modify       :
--=======================================================================
local lib = require("lua_lib")
load_lib(_ENV, lib)

local lua_type = type

local function car(element)
    if lua_type(element) ~= "table" then
        return element
    end
    return element[1]
end

local function cdr(element)
    if lua_type(element) ~= "table" then
        return nil
    end
    return element[2]
end

local function cons(element_a, element_b)
    return {element_a, element_b}
end

local function type(element)
    if tonumber(element) then
        return "num"
    end
    if lua_type(element) == "table" and element.__is_symbol then
        local symbol = element
        if tonumber(symbol()) then
            return "num"
        end
        if symbol.__function then
            return "op"
        end
        return "var"
    end
    if car(element) then
        return "pair"
    end
    return lua_type(element)
end

local function list(element, ...)
    if not element then
        return
    end
    return cons(element, list(...))
end

local function symbol(symbol_name, func)
    local symbol = {
        __is_symbol = true,
        __value = symbol_name,
        __function = func,
    }
    setmetatable(symbol, {
        __eq = function(a, b)
            return a() == b()
        end,
        __call = function(tb, ...)
            local value = tb.__value
            local func = tb.__function
            if func and select('#', ...) > 0 then
                return func(...)
            end
            return value
        end,
    })
    return symbol
end

local function isSymbol(symbol)
    if lua_type(symbol) ~= "table" then
        return false
    end
    return symbol.__is_symbol
end

local function dump(element)
    local element_type = type(element)
    if element_type ~= "pair" then
        if isSymbol(element) then
            return element()
        end
        return tostring(element)
    end
    local result_str = "("
    local function _dump(v)
        if not v then
            result_str = result_str .. ")"
            return result_str
        end
        result_str = result_str .. dump(car(v)) .. ", "
        return _dump(cdr(v))
    end
    return _dump(element)
end

local function test()
    print(type(1))
    print(type(cons(1,2)))
    print(type(symbol(3)))
    print(dump(cons(cons(cons(11,23),cons(10, 11)), cons(3,4))))
    print(dump(list(list(symbol("+", function () end), symbol("x"),3), list(symbol("+", function () end),2,3))))
end

if arg[0] == "sim_scheme.lua" then
    test()
end

return {
    car = car,
    cdr = cdr,
    cons = cons,
    dump = dump,
    list = list,
    type = type,
    isSymbol = isSymbol,
    symbol = symbol,
}
