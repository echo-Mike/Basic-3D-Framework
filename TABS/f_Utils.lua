--[[
    DESCRIPTION: 
        Module contains utilities for different applications
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.1: 
        CREATED:
            Error facility:
                void F_UTILS.error(const float error_type, ...)
            Functions:
                Codea:vec4 vmp(Codea:vec4 v, Codea:matrix m)
                Codea:vec3 v3mp(Codea:vec3 v, Codea:matrix m)
                Codea:vec4 v3to4(Codea:vec3 v)
                Codea:vec3 v4to3(Codea:vec4 v)
                void ivert(table t, ...) 
                T check(T value, string valuetype, string errortext, T errorvalue)
                T checkByMetatable(T value, T example, string errortext, T errorvalue)
                void set_rgb_colors(Codea:mesh mes)
                void gen_normals(Codea:mesh m)
                table deepCopy(table t)
                void recPrint(table t, string key)
                string string:__index(string str, int i)
                string string:__call(string str, int[table] i, int[nil] j)
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable F_UTILS
            Codea:vec4 vmp(Codea:vec4 v, Codea:matrix m)
            Codea:vec3 v3mp(Codea:vec3 v, Codea:matrix m)
            Codea:vec4 v3to4(Codea:vec3 v)
            Codea:vec3 v4to3(Codea:vec4 v)
            void ivert(table t, ...) 
            T check(T value, string valuetype, string errortext, T errorvalue)
            T checkByMetatable(T value, T example, string errortext, T errorvalue)
            void set_rgb_colors(Codea:mesh mes)
            void gen_normals(Codea:mesh m)
            table deepCopy(table t)
            void recPrint(table t, string key)
            string string:__index(string str, int i)
            string string:__call(string str, int[table] i, int[nil] j)
        LOCAL:
            variable errors   
]]
--[[
    TODOLIST:
        NON
]]
--[[
    BUGLIST:
        NON
]]
--[[
    DEPENDENCIES(STRONG):
        Codea:mesh()
        Codea:vec3()
        Codea:vec4()
        Codea:color()
]]

--Module declaration
if F_UTILS then
    print("f_Utils: F_UTILS variable is already occupied as: "..tostring(F_UTILS))
end

F_UTILS = {
    loaded = true,
    --[[
        Error facility behavior qualifier: 
        0:raise lua error
        1:print error messege to stdout
        2:print error messege to stderr
    ]]
    no_errors = 0,
    version = "0.0.1"
}

--Error declaration based on Codea autofill specifics
local errors = {}
errors.NO_CODEA = 0

--Error facility declaration
function F_UTILS.error(error_type, ...)
    local t, s = {...}, "f_Utils:"
    if error_type == errors.NO_CODEA then
        s = s.."Runing without Codea classes"
    else
        s = s.."Unknown error type"
	end
    if F_UTILS.no_errors == 1 then
        print(s)
    elseif F_UTILS.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--STRONG:
--Check Codea classes loaded
if (not mesh) or (not color) or (not vec3) or (not vec4) then
    F_UTILS.loaded = false
    F_UTILS.error(errors.NO_CODEA)
end

--Functions definition

--Vector (vec4) to matrix multiplication with w component normalisation
function vmp(v, m)
    local res = vec4(0)
    res.x = v.x*m[1]+v.y*m[5]+v.z*m[ 9]+v.w*m[13]
    res.y = v.x*m[2]+v.y*m[6]+v.z*m[10]+v.w*m[14]
    res.z = v.x*m[3]+v.y*m[7]+v.z*m[11]+v.w*m[15]
    res.w = v.x*m[4]+v.y*m[8]+v.z*m[12]+v.w*m[16]
    return res/res.w
end

--Vector (vec3) to matrix multiplication with w component normalisation (oneliner)
function v3mp(v, m)
    return vec3(v.x*m[1]+v.y*m[5]+v.z*m[9]+m[13],v.x*m[2]+v.y*m[6]+v.z*m[10]+m[14],v.x*m[3]+v.y*m[7]+v.z*m[11]+m[15])/(v.x*m[4]+v.y*m[8]+v.z*m[12]+m[16])
end

--convert vec3 to vec4 by adding 1 as v.w
function v3to4(v)
    return vec4(v.x,v.y,v.z,1)
end

--convert vec4 to vec3 with division by v.w
function v4to3(v)
    return vec3(v.x,v.y,v.z)/v.w
end

--append all parameters after first to first parameter(must be table)
function ivert(t, ...) 
    for _,v in pairs({...}) do
        table.insert(t, v)
    end
end

--Check value type, raises lua error 
function check(value, valuetype, errortext, errorvalue)
    if type(value) == valuetype then
        return value
    else
        error(errortext..tostring(value))
        return errorvalue
    end
end

--Check value and example type equivalence by comparing their metatables, raises lua error 
function checkByMetatable(value, example, errortext, errorvalue)
    if getmetatable(value) == getmetatable(example) then
        return value
    else
        error(errortext..tostring(value))
        return errorvalue
    end
end

--Sets red,green and blue color to every triangle in mesh
function set_rgb_colors(mes)
    local c = {}
    for i =1, mes.size/3 do
        table.insert(c, color(255,0,0))
        table.insert(c, color(0,255,0))
        table.insert(c, color(0,0,255))
    end
    mes.colors = c
end

--Generate normals for mesh as it pointed from (0,0,0)
function gen_normals(m)
    local t = m:buffer("position"):get()
    local n = {}
    for i = 1,#t do
        table.insert(n, t[i]:normalize())
    end
    m.normals = n
end

--Reduced and modified version of http://lua-users.org/wiki/CopyTable deepcopy(orig) function
function deepCopy(t)
    local copy
    if type(t) == 'table' then
        copy = {}
        for k, v in pairs(t) do
            copy[k] = deepCopy(v)
        end
        setmetatable(copy, getmetatable(t))
    else
        copy = t
    end
    return copy
end

--Recursively print content of variable 't'
function recPrint(t,key) 
    local key = key or "main"
    if type(t) == "table" then 
        for k,v in pairs(t) do
            recPrint(v,key.."."..tostring(k)) 
        end 
    else 
        print(key, t) 
    end 
end

--String class improvements from http://lua-users.org/wiki/StringIndexing

--Index chars in string as: string[char_position]
getmetatable('').__index = function(str,i)
    if type(i) == 'number' then
        return string.sub(str,i,i)
    else
        return string[i]
    end
end

--Index chars in string as: string(start_char_index, end_char_index) or string{index1,index2,...}
getmetatable('').__call = function(str,i,j)  
    if type(i)~='table' then 
        return string.sub(str,i,j) 
    else 
        local t={} 
        for k,v in ipairs(i) do 
            t[k]=string.sub(str,v,v) 
        end
        return table.concat(t)
    end
  end