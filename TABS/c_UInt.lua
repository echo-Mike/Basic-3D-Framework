require('Codea_classes.Class')

local UINT_MODULE = 2^32

UINT_MAX = 2^32-1

UINT_LARGE = UINT_MODULE

uint = class()

uint["__call"] = function(op)
    return op.value
end

uint["__add"] = function(op1,op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return uint(op1.value + op2.value)
    elseif is[1] and not is[2] then
        return uint(op1.value + op2)
    elseif is[2] and not is[1] then
        return uint(op2.value + op1)
    else
        error("c_UInt: Can't add objects"..tostring(op1).." and "..tostring(op2))
    end
end

uint["__sub"] = function(op1,op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return uint(op1.value - op2.value)
    elseif is[1] and not is[2] then
        return uint(op1.value - op2)
    elseif is[2] and not is[1] then
        return uint(op1 - op2.value)
    else
        error("c_UInt: Can't substarct objects"..tostring(op1).." and "..tostring(op2))
    end
end

uint["__mul"] = function(op1,op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return uint(op1.value * op2.value)
    elseif is[1] and not is[2] then
        return uint(op1.value * op2)
    elseif is[2] and not is[1] then
        return uint(op2.value * op1)
    else
        error("c_UInt: Can't multiply objects"..tostring(op1).." and "..tostring(op2))
    end
end

uint["__div"] = function(op1, op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        if op1.value < op2.value then
            return uint(0, true)
        else
            return uint(math.floor(op1.value / op2.value), true)
        end
    elseif is[1] and not is[2] then
        if op1.value < op2 then
            return uint(0, true)
        else
            return uint(op1.value / math.floor(op2))
        end
    elseif is[2] and not is[1] then
        if op1 < op2.value then
            return uint(0, true)
        else
            return uint(math.floor(op1) / op2.value)
        end
    else
        error("c_UInt: Can't divide objects"..tostring(op1).." and "..tostring(op2))
    end
end

uint["__mod"] = function(op1, op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
        if is[1] and is[2] then 
        if op1.value < op2.value then
            return uint(op1.value, true)
        else
            return uint(op1.value % op2.value, true)
        end
    elseif is[1] and not is[2] then
        if op1.value < op2 then
            return uint(op1.value, true)
        else
            return uint(op1.value % math.floor(op2))
        end
    elseif is[2] and not is[1] then
        if op1 < op2.value then
            return uint(0, true)
        else
            return uint(math.floor(op1) % op2.value)
        end
    else
        error("c_UInt: Can't divide objects"..tostring(op1).." and "..tostring(op2))
    end
end

uint["__unm"] = function(op)
    return uint(UINT_MAX - op.value, true)
end

uint["__eq"] = function(op1, op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return op1.value == op2.value
    elseif is[1] and not is[2] then
        return op1.value == op2
    elseif not is[1] and is[2] then
        return op1 == op2.value
    else
        return false
    end
end

uint["__lt"] = function(op1, op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return op1.value < op2.value
    elseif is[1] and not is[2] then
        return op1.value < op2
    elseif not is[1] and is[2] then
        return op1 < op2.value
    else
        return false
    end
end

uint["__le"] = function(op1, op2)
    local is = {uint.is_a(op1,uint), uint.is_a(op2,uint)}
    if is[1] and is[2] then 
        return op1.value <= op2.value
    elseif is[1] and not is[2] then
        return op1.value <= op2
    elseif not is[1] and is[2] then
        return op1 <= op2.value
    else
        return false
    end
end

uint["__tostring"] = function(v)
    return string.char(v.value % 256, math.floor(v.value / 256) % 256, math.floor(v.value / 65536) % 256, math.floor(v.value / 16777216) % 256)
end
        

function uint:init(value,escape)
    if escape then 
        self.value = value
        return
    end
    if value and value > 0 then
        self.value = math.floor(value) % UINT_MODULE
    elseif value and value < 0 then
        self.value = UINT_MAX - math.floor(value)
    end
end

function uint:bin_form()
    local res, buff = "", self.value
    for i =31,0,-1 do
        if buff >= 2^i then 
            res = res.."1"
            buff = buff - 2^i
        else 
            res = res.."0"
        end
        if i % 8 == 0 then res = res.." " end
    end
    return res
end

function uint:hex_form()
    return string.format("%X", self.value)
end

function uint.from_bytes(lowlow,lowhigh,highlow,highhigh)
    return uint(lowlow + lowhigh*256 + highlow*65536 + highhigh*16777216)
end

function uint.from_chars(lowlow,lowhigh,highlow,highhigh)
    return uint.from_bytes(lowlow:byte(),lowhigh:byte(),highlow:byte(),highhigh:byte())
end

function uint.from_string(s,i,j)
    local b = i or 1
    local e = j or 4
    return uint.from_bytes(s:byte(b,e))
end