require('Codea_classes.Class')

matrix = class()

matrix["__add"] = function(op1,op2)
    return matrix(
        op1[1]+op2[1], op1[2]+op2[2], op1[3]+op2[3], op1[4]+op2[4],
        op1[5]+op2[5], op1[6]+op2[6], op1[7]+op2[7], op1[8]+op2[8],
        op1[9]+op2[9], op1[10]+op2[10], op1[11]+op2[11], op1[12]+op2[12],
        op1[13]+op2[13], op1[14]+op2[14], op1[15]+op2[15], op1[16]+op2[16]
    )
end

matrix["__sub"] = function(op1,op2)
    return matrix(
        op1[1]-op2[1], op1[2]-op2[2], op1[3]-op2[3], op1[4]-op2[4],
        op1[5]-op2[5], op1[6]-op2[6], op1[7]-op2[7], op1[8]-op2[8],
        op1[9]-op2[9], op1[10]-op2[10], op1[11]-op2[11], op1[12]-op2[12],
        op1[13]-op2[13], op1[14]-op2[14], op1[15]-op2[15], op1[16]-op2[16]
    )
end

matrix["__mul"] = function(op1,op2)
    if matrix.is_a(op1, matrix) and matrix.is_a(op2, matrix) then
        local m = matrix()
        for i = 0,3 do
            for j = 1,4 do
                m[i*4+j] = op1[i*4+1]*op2[j] + op1[i*4+2]*op2[j+4] + op1[i*4+3]*op2[j+8] + op1[i*4+4]*op2[j+12]
             end
        end
        return m
    elseif matrix.is_a(op1, matrix) then
        return matrix(
            op1[1]*op2, op1[2]*op2, op1[3]*op2, op1[4]*op2,
            op1[5]*op2, op1[6]*op2, op1[7]*op2, op1[8]*op2,
            op1[9]*op2, op1[10]*op2, op1[11]*op2, op1[12]*op2,
            op1[13]*op2, op1[14]*op2, op1[15]*op2, op1[16]*op2
        )
    elseif matrix.is_a(op2, matrix) then
        return matrix(
            op2[1]*op1, op2[2]*op1, op2[3]*op1, op2[4]*op1,
            op2[5]*op1, op2[6]*op1, op2[7]*op1, op2[8]*op1,
            op2[9]*op1, op2[10]*op1, op2[11]*op1, op2[12]*op1,
            op2[13]*op1, op2[14]*op1, op2[15]*op1, op2[16]*op1
        )
    else
        error("vec3:Can't multiply by number: "..tostring(op2))
    end
end

matrix["__div"] = function(op1,op2)
    if matrix.is_a(op1) then
        return matrix(
            op1[1]/op2, op1[2]/op2, op1[3]/op2, op1[4]/op2,
            op1[5]/op2, op1[6]/op2, op1[7]/op2, op1[8]/op2,
            op1[9]/op2, op1[10]/op2, op1[11]/op2, op1[12]/op2,
            op1[13]/op2, op1[14]/op2, op1[15]/op2, op1[16]/op2
        )
    elseif matrix.is_a(op2) then
        return matrix(
            op2[1]/op1, op2[2]/op1, op2[3]/op1, op2[4]/op1,
            op2[5]/op1, op2[6]/op1, op2[7]/op1, op2[8]/op1,
            op2[9]/op1, op2[10]/op1, op2[11]/op1, op2[12]/op1,
            op2[13]/op1, op2[14]/op1, op2[15]/op1, op2[16]/op1
        )
    else
        error("matrix:Can't divide by number: "..tostring(op2))
    end
end

matrix["__unm"] = function(op)
    return matrix(
        -op[1], -op[2], -op[3], -op[4],
        -op[5], -op[6], -op[7], -op[8],
        -op[9], -op[10], -op[11], -op[12],
        -op[13], -op[14], -op[15], -op[16]
    )
end

matrix["__eq"] = function(op1, op2)
    for i = 1,16 do
        if op1[i] ~= op2[i] then return false end
    end
    return true
end

matrix["__tostring"] = function(v)
    local s = "("
    for i = 1,15 do 
        s = s..tostring(v[i])..", "
        if i%4 == 0 then
            s = s.."\n"
        end
    end
    return s..tostring(v[16])..")"
end

function matrix:init(...)
    local t = {...}
    if #t == 0 then
        for i = 1, 16 do 
            if (i == 1) or (i == 6) or (i == 11) or (i == 16) then 
                table.insert(self, i, 1)
            else
                table.insert(self, i, 0)
            end
        end
    elseif #t >= 16 then
        for i = 1, 16 do 
            table.insert(self, i, t[i])
        end
    else 
        error("Matrix:Invalid amount of arguments")
    end
end

function matrix:rotate(r,x,y,z)
    local c, s = math.cos(r), math.sin(r)
    return matrix(
        c+x*x(1-c), x*y*(1-c)-z*s, x*z*(1-c)+y*s, 0,
        y*x*(1-c)+z*s, c+y*y(1-c), y*z*(1-c)-x*s, 0,
        z*x*(1-c)-y*s, z*y*(1-c)+x*s, c+z*z(1-c), 0,
        0,0,0,1
    )*self
end

function matrix:translate(x,y,z)
    return matrix(
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        x,y,z,1
    )*self
end

function matrix:scale(x,y,z)
    return matrix(
        x,0,0,0,
        0,y,0,0,
        0,0,z,0,
        0,0,0,1
    )*self
end

function matrix:inverse()

end

function matrix:tranpose()
    local m = matrix()
    for i = 1,4 do
        for j = 1,4 do
             m[(i-1)*4+j] = self[(j-1)*4+i]
        end
    end
    return m
end

function matrix:determinant()
    
end

local function minor(i,j,m)
    
end