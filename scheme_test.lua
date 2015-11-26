--=======================================================================
-- File Name    : scheme_test
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Mon Nov 23 14:12:32 2015
-- Description  : test scheme examples
-- Modify       :
--=======================================================================
local lib = require("lua_lib")
local scheme = require("sim_scheme")

load_lib(_ENV, scheme)

local function accumulate(op, first_value, element)
    if not element then
        return first_value
    end
    return op(car(element), accumulate(op, first_value, cdr(element)))
end

local function add(a, b)
    return a + b
end

local function multi(a, b)
    return a * b
end

local function isodd(v)
    if v % 2 == 1 then
        return true
    end
    return false
end

local function iseven(v)
    if v % 2 == 1 then
        return false
    end
    return true
end

local function filter(judge_func, element)
    if not element then
        return
    end
    if judge_func(car(element)) then
        return cons(car(element), filter(judge_func, cdr(element)))
    else
        return filter(judge_func, cdr(element))
    end
end

local function enumlate(num)
    local function _iter(index, num)
        if index > num then
            return
        end
        return cons(index, _iter(index + 1, num))
    end
    return _iter(1, num)
end

local function map(tb, op)
    if not tb then
        return
    end
    return cons(op(car(tb)), map(cdr(tb), op))
end

print("raw list")
print(dump(enumlate(6)))

print("odd list")
print(dump(filter(isodd, enumlate(6))))

print("odd sum")
print(dump(accumulate(add, 0, filter(isodd,enumlate(6)))))

print("odd multi")
print(dump(accumulate(multi, 1, filter(isodd,enumlate(6)))))

print("even list")
print(dump(filter(iseven,enumlate(6))))

print("even sum")
print(dump(accumulate(add, 0, filter(iseven,enumlate(6)))))

print("even multi")
print(dump(accumulate(multi, 1, filter(iseven,enumlate(6)))))

print("map")
print(dump(map(enumlate(6), function(v) return v * 2 end)))

print("map(odd + 1) sum")
print(dump(accumulate(add, 0, map(filter(isodd,enumlate(6)), function(v) return v + 1 end))))
