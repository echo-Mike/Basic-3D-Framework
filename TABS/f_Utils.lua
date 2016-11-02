--DESCRIPTION: Module contains utilites fo differet applications: vpm; v3to4; v4to3; ivert; check; set_rgb_colors.
if not F_UTILS then
    F_UTILS = true
end

--vector (vec4) to matrix multiplication with w component normalisation
function vmp(v, m)
    local res = vec4(0)
    res.x = v.x*m[1]+v.y*m[5]+v.z*m[ 9]+v.w*m[13]
    res.y = v.x*m[2]+v.y*m[6]+v.z*m[10]+v.w*m[14]
    res.z = v.x*m[3]+v.y*m[7]+v.z*m[11]+v.w*m[15]
    res.w = v.x*m[4]+v.y*m[8]+v.z*m[12]+v.w*m[16]
    return res/res.w
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
    --local bt = {..}
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

--sets red,green and blue color to every triangle in mesh
function set_rgb_colors(mes)
    local c = {}
    for i =1, mes.size/3 do
        table.insert(c, color(255,0,0))
        table.insert(c, color(0,255,0))
        table.insert(c, color(0,0,255))
    end
    mes.colors = c
end
