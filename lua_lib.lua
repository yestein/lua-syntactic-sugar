--=======================================================================
-- File Name    : lua_lib.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/11/24 18:41:55
-- Description  : common function
-- Modify       :
--=======================================================================

function load_lib(env, lib)
    for k, v in pairs(lib) do
        env[k] = v
    end
end

local Lib = {}

function Lib.ShowTB(table_raw, n)
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
        for k, v in pairs(table) do
            if type(v) ~= "table" then
                print(string.format("%s[%s] = %s", str_blank, tostring(k), tostring(v)))
            else
                print(string.format("%s[%s] = ", str_blank, tostring(k)))
                showTB(v, deepth + 1, max_deepth)
            end
        end
    end
    showTB(table_raw, 1, n)
end

function Lib.CountTB(table)
    local count = 0
    for k, v in pairs(table) do
        count = count + 1
    end
    return count
end

return Lib
