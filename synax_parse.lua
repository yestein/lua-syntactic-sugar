--=======================================================================
-- File Name    : synax_parse.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/26 17:11:06
-- Description  : generate synax parse tree
-- Modify       :
--=======================================================================

local ParseExpression
local ParseTerm
local ParseFactor
local ParseAbs
local ParseElem

ParseExpression = function(token_pool)
    local tree_root = ParseTerm(token_pool)
    local token = token_pool.GetToken()
    local token_type
    if not token then
        goto Exit1
    end
    token_type = token.GetType()
    while token_type == "ADD" or token_type == "SUB" do
        local tree_node = {
            value = token,
            left = tree_root,
            right = ParseTerm(token_pool),
        }
        tree_root = tree_node
        token = token_pool.GetToken()
        if not token then
            goto Exit1
        end
        token_type = token.GetType()
    end
    token_pool.BackToken()

::Exit1::
    return tree_root
end

ParseTerm = function(token_pool)
    local tree_root = ParseFactor(token_pool)
    local token = token_pool.GetToken()
    local token_type
    if not token then
        goto Exit1
    end
    token_type = token.GetType()
    while token_type == "MUL" or token_type == "DIV" do
        local tree_node = {
            value = token,
            left = tree_root,
            right = ParseFactor(token_pool),
        }
        tree_root = tree_node
        token = token_pool.GetToken()
        if not token then
            goto Exit1
        end
        token_type = token.GetType()
    end
    token_pool.BackToken()
::Exit1::
    return tree_root
end

ParseFactor = function(token_pool)
    local tree_root
    local token = token_pool.GetToken()
    local token_type = token.GetType()
    if token_type == "ADD" or token_type == "SUB" then
        tree_root = {
            value = token,
            right = ParseFactor(token_pool),
        }
    else
        token_pool.BackToken()
        tree_root = ParseAbs(token_pool);
    end

    return tree_root
end

ParseAbs = function(token_pool)
    local tree_root
    local token = token_pool.GetToken()
    local token_type = token.GetType()

    if token_type == "LP" then
        tree_root = ParseExpression(token_pool)
        token = token_pool.GetToken(token_pool);
        token_type = token.GetType()
        assert(token_type == "RP")
    else
        token_pool.BackToken()
        tree_root = ParseElem(token_pool)
    end
    return tree_root
end

ParseElem = function(token_pool)
    local tree_root
    local token = token_pool.GetToken()
    local token_type
    if not token then
        goto Exit1
    end
    token_type = token.GetType()

    if token_type == "ID" or token_type == "NUMBER" then
        tree_root = {
            value = token
        }
    else
        assert(false)
    end
::Exit1::
    return tree_root
end

-- local TOKEN_OP_JUDGE
-- local PARSE_FUNC

-- local function Parse(token_pool, bnf_name)
--     local tree_root = sub_parse(token_pool)
--     local token = token_pool.GetToken()
--     local token_type = token.GetType()
--     while token_judge(token_type) do
--         local tree_node = {
--             value = token,
--             left = tree_root,
--             right = sub_parse(token_pool, sub_parse),
--         }
--         tree_root = tree_node
--         token = token_pool.GetToken()
--     end
--     token_pool.BackToken()

--     return tree_root
-- end

-- TOKEN_OP_JUDGE = {
--     ["EXP"] = function(token_type)
--         return token_type == "ADD" or token_type == "SUB"
--     end,
--     ["TERM"] = function(token_type)
--         return token_type == "MUL" or token_type == "DIV"
--     end,
--     ["FACTOR"] = function(token_type)
--         return token_type == "ADD" or token_type == "SUB"
--     end,
-- }

-- PARSE_FUNC ={
--     ["EXP"] = {Parse, "TERM"}
--     ["TERM"] = {Parse, "FACTOR"}
-- }

local function DumpTree(tree)
    if not tree then
        return
    end

    local str = "(" .. tree.value.GetExpression()
    local left_str = DumpTree(tree.left)
    if left_str then
        str = str .. " " .. left_str
    end
    local right_str = DumpTree(tree.right)
    if right_str then
        str = str .. " " .. right_str
    end
    str = str .. ")"
    return str
end

local function DumpTree2(table_raw, n)
    if not table_raw then
        print("nil")
        return
    end
    if not n then
        n = 1
    end
    local function showTB(table, deepth, max_deepth)
        if deepth > n or deepth > max_deepth then
            return
        end
        local str_blank = ""
        for i = 1, deepth - 1 do
            str_blank = str_blank .. "  "
        end
        print(string.format("%s[value] = %s", str_blank, (table.value.GetExpression())))

        if table.left then
            print(string.format("%s[left] = ", str_blank))
            showTB(table.left, deepth + 1, max_deepth)
        end

        if table.right then
            print(string.format("%s[right] = ", str_blank))
            showTB(table.right, deepth + 1, max_deepth)
        end
    end
    showTB(table_raw, 1, n)
end

if arg[0] == "synax_parse.lua" then
    local lex = require("lex_analysis")
    local parser = lex.GetLexParser("lex_rule.lua")
    local token_pool = parser("x*(-2+3)*x")
    for i, token in ipairs(token_pool.GetAll()) do
        print(i, token.GetExpression(), token.GetType())
    end
    local tree = ParseExpression(token_pool)
    print(DumpTree(tree))
    print(DumpTree2(tree, 7))
end


return {
    Parse = function(lex_parser, expression)
        local token_pool = lex_parser(expression)
        return ParseExpression(token_pool), token_pool
    end,
    Dump = DumpTree,
}
