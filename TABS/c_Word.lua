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
        return op1.value == op2
    elseif not is[1] and is[2] then
        return op1 == op2.value
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

function word:hex_form()
    return string.format("%X", self.value)
end

function word.from_bytes(low,high)
    return word(low + high*256)
end

function word.from_chars(low,high)
    return word.from_bytes(low:byte(),high:byte())
end

function word.from_string(s,i,j)
    local b = i or 1
    local e = j or 2
    return word.from_bytes(s:byte(b,e))
end

