require('Codea_classes.Class')

vec3 = class()

vec3["__add"] = function(op1,op2)
    return vec3(op1.x+op2.x, op1.y+op2.y, op1.z+op2.z)
end

vec3["__sub"] = function(op1,op2)
    return vec3(op1.x-op2.x, op1.y-op2.y, op1.z-op2.z)
end

vec3["__mul"] = function(op1,op2)
    if op1.x then
        return vec3(op1.x*op2, op1.y*op2, op1.z*op2)
    elseif op2.x then
        return vec3(op2.x*op1, op2.y*op1, op2.z*op1)
    else    
        error("vec3:Can't multiply by number: "..tostring(op2))
    end
end

vec3["__div"] = function(op1,op2)
    if op1.x then
        return vec3(op1.x/op2, op1.y/op2, op1.z/op2)
    elseif op2.x then
        return vec3(op2.x/op1, op2.y/op1, op2.z/op1)
    else    
        error("vec3:Can't divide by number: "..tostring(op2))
    end
end

vec3["__pow"] = function(op1,op2)
    if op1.x then
        return vec3(op1.x^op2, op1.y^op2, op1.z^op2)
    else    
        error("vec3:Can't raise to: "..tostring(op2))
    end
end

vec3["__unm"] = function(op)
    return vec3(-op.x, -op.y, -op.z)
end

vec3["__eq"] = function(op1, op2)
    return (op1.x == op2.x) and (op1.y == op2.y) and (op1.z == op2.z)
end

vec3["__tostring"] = function(v)
    return "("..tostring(v.x)..", "..tostring(v.y)..", "..tostring(v.z)..")"
end

function vec3:init(x,y,z)
    self.x = x or 0
    self.y = y or self.x
    self.z = z or self.x
end

function vec3:dot(v)
    return self.x*v.x + self.y*v.y + self.z*v.z
end

function vec3:normalize()
    return self/self:len()
end

function vec3:dist(v)
    return (self - v):len()
end

function vec3:distSqr(v)
    return (self - v):lenSqr()
end

function vec3:len()
    return math.sqrt(self:lenSqr())
end

function vec3:lenSqr()
    return self.x^2 + self.y^2 + self.z^2
end

function vec3:cross(v)
    return vec3(self.y*v.z-self.z*v.y, self.z*v.x-self.x*v.z, self.x*v.y-self.y*v.z)
end

function vec3:unpack()
    return self.x, self.y, self.z
end


vec4 = class()

vec4["__add"] = function(op1,op2)
    return vec4(op1.x+op2.x, op1.y+op2.y, op1.z+op2.z, op1.w+op2.w)
end

vec4["__sub"] = function(op1,op2)
    return vec4(op1.x-op2.x, op1.y-op2.y, op1.z-op2.z, op1.w-op2.w)
end

vec4["__mul"] = function(op1,op2)
    if op1.x then
        return vec4(op1.x*op2, op1.y*op2, op1.z*op2, op1.w*op2)
    elseif op2.x then
        return vec4(op2.x*op1, op2.y*op1, op2.z*op1, op2.w*op1)
    else    
        error("vec4:Can't multiply by number: "..tostring(op2))
    end
end

vec4["__div"] = function(op1,op2)
    if op1.x then
        return vec4(op1.x/op2, op1.y/op2, op1.z/op2, op1.w/op2)
    elseif op2.x then
        return vec4(op2.x/op1, op2.y/op1, op2.z/op1, op2.w/op1)
    else    
        error("vec4:Can't divide by number: "..tostring(op2))
    end
end

vec4["__pow"] = function(op1,op2)
    if op1.x then
        return vec4(op1.x^op2, op1.y^op2, op1.z^op2, op1.w^op2)
    else    
        error("vec4:Can't raise to: "..tostring(op2))
    end
end

vec4["__unm"] = function(op)
    return vec4(-op.x, -op.y, -op.z, -op.w)
end

vec4["__eq"] = function(op1, op2)
    return (op1.x == op2.x) and (op1.y == op2.y) and (op1.z == op2.z) and (op1.w == op2.w)
end

vec4["__tostring"] = function(v)
    return "("..tostring(v.x)..", "..tostring(v.y)..", "..tostring(v.z)..", "..tostring(v.w)..")"
end

function vec4:init(x,y,z,w)
    self.x = x or 0
    self.y = y or self.x
    self.z = z or self.x
    self.w = w or self.x
end

function vec4:dot(v)
    return self.x*v.x + self.y*v.y + self.z*v.z + self.w*v.w
end

function vec4:normalize()
    return self/self:len()
end

function vec4:dist(v)
    return (self - v):len()
end

function vec4:distSqr(v)
    return (self - v):lenSqr()
end

function vec4:len()
    return math.sqrt(self:lenSqr())
end

function vec4:lenSqr()
    return self.x^2 + self.y^2 + self.z^2 + self.w^2
end

function vec4:unpack()
    return self.x, self.y, self.z, self.w
end

