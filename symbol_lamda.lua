--=======================================================================
-- File Name    : symbol_lamda.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/24 18:55:41
-- Description  : simulate symobl lambda calculate
-- Modify       :
--=======================================================================
local lib = require("lua_lib")
local scheme = require("sim_scheme")

load_lib(_ENV, lib)
load_lib(_ENV, scheme)

-- Key Words Define
local IsVar
local IsNum
local parse_exp

IsVar = function(element)
    return type(element) == "var"
end

IsNum = function(element)
    return type(element) == "num"
end

local function addend(exp)
    return car(cdr(exp))
end

local function augend(exp)
    return car(cdr(cdr(exp)))
end

local function multiplier(exp)
    return car(cdr(exp))
end

local function multiplicand(exp)
    return car(cdr(cdr(exp)))
end

local function make_sum(e1, e2)
    return list(symbol("+"), e1, e2)
end

local function make_product(e1, e2)
    return list(symbol("*"), e1, e2)
end

local function deriv(exp, var)
    local exp_type = type(exp)
    if exp_type ==  "num" then
        return 0
    elseif exp_type == "var" then
        if exp == var then
            return 1
        else
            return 0
        end
    elseif exp_type == "pair" then
        op = car(exp)
        if op() == "+" then
            return make_sum(deriv(addend(exp), var), deriv(augend(exp), var))
        elseif op() == '*' then
            return make_sum(
                make_product(multiplier(exp), deriv(multiplicand(exp), var)),
                make_product(deriv(multiplier(exp), var), multiplicand(exp))
            )
        else
            print("error unknown expression")
        end
    else
        print(exp_type)
        ShowTB(exp)
        print(isSymbol(exp))
        print(type(exp))
    end
end

local function Test()
    local function TestisSymbol()
        print("TestisSymbol")
        print('var = +', isSymbol(symbol('+', function(a, b) return a + b end)))
        print('var = \'x\'', isSymbol(symbol('x')))
        print('var = 3', isSymbol(symbol(3)))
        print('var = \'3\'', isSymbol(symbol('3')))
        print(3, isSymbol(3))
    end

    local function TestSymbolEqual()
        print("TestSymbolEqual")
        print('x, y', symbol('x') == symbol('y'))
        print('x, x', symbol('x') == symbol('x'))
    end

    local function TestIsVar()
        print("TestIsVar")
        print('x', IsVar(symbol('x')))
        print('\'3\'', IsVar(symbol('3')))
        print('3', IsVar(symbol(3)))
    end

    local function TestIsNum()
        print("TestIsNum")
        print('3', IsNum(3))
        print('3', IsNum(symbol(3)))
        print('3', IsNum(symbol("3")))
    end

    local function TestExp()
        print("TestExp")
        print(type(list(symbol("+"), symbol('x'), 3)))
    end

    local function TestDerive()
        print("TestDerive")
        print(dump(deriv(
            list(symbol("*"), symbol("x"),
                list(symbol("*"), symbol('x'), symbol('3'))
            ),
             symbol("x"))))
    end
    TestisSymbol()
    TestSymbolEqual()
    TestIsVar()
    TestIsNum()
    TestExp()
    TestDerive()
end

if arg[0] == "symbol_lamda.lua" then
    Test()
end

