--=======================================================================
-- File Name    : symbol_lamda.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/24 18:55:41
-- Description  : simulate symobl lambda calculate
-- Modify       :
--=======================================================================
local lib = require("lua_lib")
local scheme = require("sim_scheme")
local lex = require("lex_analysis")
local synax = require("synax_parse")

load_lib(_ENV, lib)
load_lib(_ENV, scheme)

-- Key Words Define
local IsVar
local IsNum
local parse_exp

IsVar = function(element)
    return scm_type(element) == "var"
end

IsNum = function(element)
    return type(element) == "number" or scm_type(element) == "num"
end

local function generateAdd()
    return symbol('+',
        function(a, b)
            if scm_type(a) == "num" and scm_type(b) == "num" then
                return symbol(tonumber(a()) + tonumber(b()))
            elseif scm_type(a) == "num" and tonumber(a()) == 0 then
                return b
            elseif scm_type(b) == "num" and tonumber(b()) == 0 then
                return a
            end
            return list(generateAdd(), a, b)
        end
    )
end

local function generateSub()
    return symbol('-',
        function(a, b)
            if scm_type(a) == "num" and not b then
                return symbol(tonumber(a()) * -1)
            elseif scm_type(a) == "num" and scm_type(b) == "num" then
                return symbol(tonumber(a()) - tonumber(b()))
            elseif scm_type(a) == "num" and tonumber(a()) == 0 then
                return b
            elseif scm_type(b) == "num" and tonumber(b()) == 0 then
                return a
            end
            return list(generateSub(), a, b)
        end
    )
end

local function generateMul()
    return symbol('*',
        function(a, b)
            if scm_type(a) == "num" and scm_type(b) == "num" then
                return symbol(tonumber(a()) * tonumber(b()))
            elseif (scm_type(a) == "num" and tonumber(a()) == 0) or (scm_type(b) == "num" and tonumber(b()) == 0) then
                return symbol(0)
            elseif scm_type(a) == "num" and tonumber(a()) == 1 then
                return b
            elseif scm_type(b) == "num" and tonumber(b()) == 1 then
                return a
            end
            return list(generateMul(), a, b)
        end
    )
end

local function generateDiv()
    return symbol('/',
        function(a, b)
            if (scm_type(b) == "num" and tonumber(b()) == 0) then
                assert(false)
            elseif (scm_type(a) == "num" and tonumber(a()) == 0) then
                return symbol(0)
            elseif scm_type(a) == "num" and scm_type(b) == "num" then
                return symbol(tonumber(a()) / tonumber(b()))
            elseif scm_type(a) == "num" and tonumber(a()) == 1 then
                return b
            elseif scm_type(b) == "num" and tonumber(b()) == 1 then
                return a
            end
            return list(generateMul(), a, b)
        end
    )
end

local function make_op(op_func, e1, e2)
    return list(op_func(), e1, e2)
end

local function exp(expression)
    local syntax_tree, token_pool = synax.Parse(lex.GetLexParser("lex_rule.lua"), expression)
    local function genSymbol(token)
        if token.GetExpression() == '+' then
            return generateAdd()
        elseif token.GetExpression() == '-' then
            return generateSub()
        elseif token.GetExpression() == '*' then
            return generateMul()
        elseif token.GetExpression() == "/" then
            return generateDiv()
        end
        return symbol(token.GetExpression())
    end
    local function _exp_real(tree)
        if not tree then
            return
        end
        if tree.left then
            return list(genSymbol(tree.value), _exp_real(tree.left), _exp_real(tree.right))
        elseif tree.right then
            return list(genSymbol(tree.value), _exp_real(tree.right))
        else
            return genSymbol(tree.value)
        end
    end
    return _exp_real(syntax_tree)
end

local function exp2str(expression)
    if scm_type(expression) ~= "pair" then
        if isSymbol(expression) then
            return expression()
        else
            return tostring(expression)
        end
    end
    local element = car(expression)
    local param1 = car(cdr(expression))
    local param2 = car(cdr(cdr(expression)))
    if param1 and param2 then
        return "(" .. exp2str(param1) .. element() .. exp2str(param2) .. ")"
    elseif not param2 then
        return "(" .. element() .. exp2str(param1) .. ")"
    else
        return element()
    end
end

local function deriv(exp, var)
    if not exp then
        return
    end
    local exp_type = scm_type(exp)
    if exp_type ==  "num" then
        return symbol(0)
    elseif exp_type == "var" then
        if exp == var then
            return symbol(1)
        else
            return symbol(0)
        end
    elseif exp_type == "pair" then
        op = car(exp)
        if op() == "+" then
            return make_op(generateAdd, deriv(cadr(exp), var), deriv(caddr(exp), var))
        elseif op() == "-" then
            return make_op(generateSub, deriv(cadr(exp), var), deriv(caddr(exp), var))
        elseif op() == '*' then
            return make_op(generateAdd,
                make_op(generateMul, cadr(exp), deriv(caddr(exp), var)),
                make_op(generateMul, deriv(cadr(exp), var), caddr(exp))
            )
        else
            print("error unknown expression")
        end
    else
        print(exp_type)
        ShowTB(exp)
        print(isSymbol(exp))
        print(scm_type(exp))
    end
end

local function TransSimple(expression)
    if isSymbol(expression) then
        return expression
    end
    local element = car(expression)
    if scm_type(element) == "op" then
        return element.__function(TransSimple(cadr(expression)), TransSimple(caddr(expression)))
    end
    return element
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
        print(dump(exp("-2 * 1 + 0 * x + 2 * 3 + 1*y")))
    end

    local function TestTransSimple()
        print("TestTransSimple")
        local exp2 = exp("-2 * 1 + 0 * x + 2 * 3 + 1*y")
        print(dump(TransSimple(exp2)))
        print(dump(exp2str(TransSimple(exp2))))
    end

    local function TestDerive()
        print("TestDerive")
        local expression = exp("-3 * x * x")
        print(exp2str(expression))
        print(exp2str(TransSimple(deriv(expression, symbol("x")))))
    end
    -- TestisSymbol()
    -- TestSymbolEqual()
    -- TestIsVar()
    -- TestIsNum()
    TestExp()
    TestTransSimple()
    TestDerive()
end

if arg[0] == "symbol_lamda.lua" then
    Test()
end

