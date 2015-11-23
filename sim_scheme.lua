--=======================================================================
-- File Name    : sim_scheme.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Mon Nov 23 14:04:11 2015
-- Description  : a syntactic sugar to simulate scheme
-- Modify       :
--=======================================================================

local function car(element)
    if type(element) ~= "table" then
        return element
    end
    return element[1]
end

local function cdr(element)
    if type(element) ~= "table" then
        return nil
    end
    return element[2]
end

local function cons(element_a, element_b)
    return {element_a, element_b}
end

local function dump(element)
    if type(element) ~= "table" then
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
    print(dump(cons(cons(cons(11,23),cons(10, 11)), cons(3,4))))
end

-- test()

return {
    car = car,
    cdr = cdr,
    cons = cons,
    dump = dump,
}
