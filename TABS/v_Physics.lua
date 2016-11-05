--DESCRIPTION: Module contains implementation of model class

if V_PHYSICS then
    error("V_Physics: V_PHYSICS variable is already occupied as: "..tostring(V_PHYSICS))
end

V_PHYSICS = {}

local V_PHYSICS.SORT_AXIS = "x"

--Reduced and modified version of http://lua-users.org/wiki/CopyTable deepcopy(orig) function
local function deep_copy(t)
    local copy
    if type(t) == 'table' then
        copy = {}
        for k, v in pairs(t) do
            copy[k] = deep_copy(v)
        end
        setmetatable(copy, getmetatable(t))
    else
        copy = t
    end
    return copy
end

local function position_table_bound(t)
    local min, max = {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0}
    for _,v in pairs(t) do
        min.x = math.min(v.x,min.x)
        min.y = math.min(v.y,min.y)
        min.z = math.min(v.z,min.z)
        max.x = math.max(v.x,max.x)
        max.y = math.max(v.y,max.y)
        max.z = math.max(v.z,max.z)
    end
    return min, max
end

foo = function(t,key) 
    if type(t) == "table" then 
        for k,v in pairs(t) do
            foo(v,key.."."..tostring(k)) 
        end 
    else 
        print(key, t) 
    end 
end

local V_PHYSICS.AABB = {
    min = {x = 0, y = 0, z = 0},
    max = {x = 0, y = 0, z = 0},
    owner = 0,
    live = true
}

local V_PHYSICS.AABB_vector = {}

local V_PHYSICS.space = {
    dynamic = {},
    static = {}
}

V_PHYSICS.size = function() return #V_PHYSICS.AABB_vector end

function V_PHYSICS.model_construct_OBB(model)
    local min, max = position_table_bound(((model:bake()):buffer("position")):get())
    model.OBB = {}
    model.OBB[1] = vec3(max.x, max.y, max.z)
    model.OBB[2] = vec3(max.x, max.y, min.z)
    model.OBB[3] = vec3(max.x, min.y, max.z)
    model.OBB[4] = vec3(max.x, min.y, min.z)
    model.OBB[5] = vec3(min.x, max.y, max.z)
    model.OBB[6] = vec3(min.x, max.y, min.z)
    model.OBB[7] = vec3(min.x, min.y, max.z)
    model.OBB[8] = vec3(min.x, min.y, min.z)
end

function V_PHYSICS.model_construct_AABB(model)
    V_PHYSICS.model_construct_OBB(model)
    model.AABB = deep_copy(V_PHYSICS.AABB)
    model.AABB.owner = model
    table.insert(V_PHYSICS.AABB_vector, model.AABB)
    V_PHYSICS.model_update_AABB(model)
end

function V_PHYSICS.model_update_AABB(model)
    local obb = {}
    for i,v in ipairs(model.OBB) do
        obb[i] = v3mp(v, model.model_transform_matrix)
    end
    model.AABB.min, model.AABB.max = position_table_bound(obb)
end

function V_PHYSICS.test_AABB_collision(a, b)
    if a.max.x < b.min.x or a.min.x > b.max.x then return false end
    if a.max.y < b.min.y or a.min.y > b.max.y then return false end
    if a.max.z < b.min.z or a.min.z > b.max.z then return false end
    return true
end

