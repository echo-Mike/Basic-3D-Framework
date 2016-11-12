require('Codea_classes.Class')

local WORD_MODULE = 2^16

WORD_MAX = 2^16-1

WORD_LARGE = WORD_MODULE

word = class()

word["__call"] = function(op)
    return op.value
end

word["__add"] = function(op1,op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
    if is[1] and is[2] then 
        return word(op1.value + op2.value)
    elseif is[1] and not is[2] then
        return word(op1.value + op2)
    elseif is[2] and not is[1] then
        return word(op2.value + op1)
    else
        error("c_Word: Can't add objects"..tostring(op1).." and "..tostring(op2))
    end
end

word["__sub"] = function(op1,op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
    if is[1] and is[2] then 
        return word(op1.value - op2.value)
    elseif is[1] and not is[2] then
        return word(op1.value - op2)
    elseif is[2] and not is[1] then
        return word(op1 - op2.value)
    else
        error("c_Word: Can't substarct objects"..tostring(op1).." and "..tostring(op2))
    end
end

word["__mul"] = function(op1,op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
    if is[1] and is[2] then 
        return word(op1.value * op2.value)
    elseif is[1] and not is[2] then
        return word(op1.value * op2)
    elseif is[2] and not is[1] then
        return word(op2.value * op1)
    else
        error("c_Word: Can't multiply objects"..tostring(op1).." and "..tostring(op2))
    end
end

word["__div"] = function(op1, op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
    if is[1] and is[2] then 
        if op1.value < op2.value then
            return word(0, true)
        else
            return word(math.floor(op1.value / op2.value), true)
        end
    elseif is[1] and not is[2] then
        if op1.value < op2 then
            return word(0, true)
        else
            return word(op1.value / math.floor(op2))
        end
    elseif is[2] and not is[1] then
        if op1 < op2.value then
            return word(0, true)
        else
            return word(math.floor(op1) / op2.value)
        end
    else
        error("c_Word: Can't divide objects"..tostring(op1).." and "..tostring(op2))
    end
end

word["__mod"] = function(op1, op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
        if is[1] and is[2] then 
        if op1.value < op2.value then
            return word(op1.value, true)
        else
            return word(op1.value % op2.value, true)
        end
    elseif is[1] and not is[2] then
        if op1.value < op2 then
            return word(op1.value, true)
        else
            return word(op1.value % math.floor(op2))
        end
    elseif is[2] and not is[1] then
        if op1 < op2.value then
            return word(0, true)
        else
            return word(math.floor(op1) % op2.value)
        end
    else
        error("c_Word: Can't divide objects"..tostring(op1).." and "..tostring(op2))
    end
end

word["__unm"] = function(op)
    return word(WORD_MAX - op.value, true)
end

word["__eq"] = function(op1, op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
    if is[1] and is[2] then 
        return op1.value == op2.value
    elseif is[1] and not is[2] then
        if type(op2) == "string" then
            return tostring(op1) == op2
        else
            return op1.value == op2
        end
    elseif not is[1] and is[2] then
        if type(op1) == "string" then
            return op1 == tostring(op2)
        else
            return op1 == op2.value
        end
    else
        return false
    end
end

word["__lt"] = function(op1, op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
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

word["__le"] = function(op1, op2)
    local is = {word.is_a(op1,word), word.is_a(op2,word)}
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

--Represent value as 2 char string
word["__tostring"] = function(v)
    return string.char(v.value % 256, math.floor(v.value/256) % 256)
end

function word:init(value,escape)
    if escape then 
        self.value = value
        return
    end
    if value and value > 0 then
        self.value = math.floor(value) % WORD_MODULE
    else
        self.value = WORD_MAX - math.floor(value)
    end
end

--Return string with BIN form of value, lower byte on right
function word:bin_form()
    local res, buff = "", self.value
    for i = 15,0,-1 do
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

--Return string with HEX form of value, lower byte on right
function word:hex_form()
    return string.format("%X", self.value)
end

--Create uint from 2 bytes - (0:255) values 
function word.from_bytes(low,high)
    local l = low or 0
    local h = high or 0
    return word(low + high*256)
end

--Create uint from 2 chars
function word.from_chars(low,high)
    return word.from_bytes(low:byte(),high:byte())
end

--Create word from string where lower byte on i place and highest on j place 
function word.from_string(s,i,j)
    local b = i or 1
    local e = j or 2
    return word.from_bytes(s:byte(b,e))
end

--[[ FOR LUA 5.1 - 5.3
    LUA firstly compares type of variables, 
    then compares their metatables,
    and only then calls metametod, 
    so if you need to compare two variables of separate types 
    you need to do it without ==, >=, <=, <,> signs
    This mechanism is described here in "eq" section:
    http://www.lua.org/manual/5.1/manual.html#2.8
    and here:
    http://www.lua.org/manual/5.3/manual.html#2.4
]]

function word.eq(op1,op2)
    return word.__eq(op1,op2)
end

function word.neq(op1,op2)
    return not word.__eq(op1,op2)
end

function word.lt(op1,op2)
    return word.__lt(op1,op2)
end

function word.le(op1,op2)
    return word.__le(op1,op2)
end

function word.bt(op1,op2)
    return not word.__le(op1,op2)
end

function word.be(op1,op2)
    return not word.__lt(op1,op2)
end