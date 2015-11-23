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

print(dump(cons(cons(cons(11,23),cons(10, 11)), cons(3,4))))

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
