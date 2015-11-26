--=======================================================================
-- File Name    : lex_analysis.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/26 11:38:27
-- Description  : lexical analysis helper
-- Modify       :
--=======================================================================

local function ParseSymbol(DFA, lex, before_state, final_state)
    if lex == "l" then
        local c_start = string.byte("a", 1)
        for i = 1, 26 do
            local c = string.char(i + c_start - 1)
            if not DFA[before_state] then
                DFA[before_state] = {}
            end
            assert(not DFA[before_state][c], c)
            DFA[before_state][c] = final_state
        end
    elseif lex == "n" then
        local c_start = string.byte("0", 1)
        for i = 1, 10 do
            local c = string.char(i + c_start - 1)
            if not DFA[before_state] then
                DFA[before_state] = {}
            end
            -- assert(not DFA[before_state][c], c)
            DFA[before_state][c] = final_state
        end
    else
        assert(false, lex)
    end
    return 1
end

local function ParseLexRule(DFA, lex, raw_state, final_state)
    local cur_state = raw_state
    local last_state = cur_state
    local i = 1
    local count = #lex
    while i <= count do
        local c = lex:sub(i, i)
        if c == "@" then
            i = i + 1
            c = lex:sub(i, i)
            if c == "|" then
                local si, ei = lex:sub(i + 1, count):find("|")
                if not si then
                    si = count + 1
                    ei = count + 1
                end
                local sub_lex = lex:sub(i + 1, i + si - 1)
                ParseLexRule(DFA, sub_lex, last_state, final_state)
                cur_state = final_state;
                i = i + ei
            elseif c == "(" then
                local si, ei = lex:sub(i + 1, count):find(")")
                local sub_lex = lex:sub(i + 1, i + si - 1)
                nRetCode = ParseLexRule(DFA, sub_lex, cur_state, final_state)
                last_state = cur_state;
                cur_state = final_state;
                i = i + ei
            else
                ParseSymbol(DFA, c, cur_state, final_state);
                last_state = cur_state;
                cur_state = final_state;
            end
        else
            if not DFA[cur_state] then
                DFA[cur_state] = {}
            end
            if not DFA[cur_state][c] then
                DFA[cur_state][c] = final_state
            end
            cur_state = DFA[cur_state][c]
        end
        i = i + 1
    end
    return 1
end

local function GetLexParser(file_path)
    local lex_rule = dofile(file_path)
    local DFA = {}
    for i, symbol_info in ipairs(lex_rule.SYMBOL) do
        ParseLexRule(DFA, symbol_info[2], 1, i + 1)
    end

    return function(expression)
        local token_list = {}
        local i = 1
        local count = #expression
        while i <= count do
            local c = expression:sub(i, i)
            if c ~= " " and c ~= "\t" then
                local state = 1
                local si = i
                local ei = i

                while DFA[state] and DFA[state][c] do
                    state = DFA[state][c]
                    i = i + 1
                    c = expression:sub(i, i)
                end
                i = i - 1
                ei = i
                local _expression = expression:sub(si, ei)
                local _type = lex_rule.SYMBOL[state - 1][1]
                table.insert(token_list,
                    {
                        GetType = function()
                            return _type
                        end,
                        GetExpression = function()
                            return _expression
                        end,
                    }
                )
            end
            i = i + 1
        end

        local index = 0
        return{
            GetToken = function()
                index = index + 1
                return token_list[index]
            end,
            BackToken = function()
                index = index - 1
                return token_list[index]
            end,
            GetAll = function()
                return token_list
            end,
        }

    end
end

if arg[0] == "lex_analysis.lua" then
    local parser = GetLexParser("lex_rule.lua")
    local token_pool = parser("x+2+3")
    local token = token_pool.GetToken()
    while token do
        print(token.GetExpression(), token.GetType())
        token = token_pool.GetToken()
    end
end

return {GetLexParser = GetLexParser}
