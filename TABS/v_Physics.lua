--DESCRIPTION: Module contains implementation of model class

if V_PHYSICS then
    error("V_Physics: V_PHYSICS variable is already occupied as: "..tostring(V_PHYSICS))
end

V_PHYSICS = {}

V_PHYSICS.SORT_AXIS = "x"

V_PHYSICS.block_size = vec3(5000)

V_PHYSICS.world_size = vec3(100000)

V_PHYSICS.AABB_vector = {}

V_PHYSICS.queue = {}

local function position_table_bound(t, mi, ma)
    local min = mi or vec3(0)
    local max = ma or vec3(0)
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

function V_PHYSICS.model_construct_OBB(model)
    local buff = 0
    local min, max = vec3(0), vec3(0)
    for i,v in ipairs(model.meshes) do
        buff = v:buffer("position")
        if buff then
            buff = buff:get()
            for j,f in ipairs(buff) do
                buff[j] = v3mp(f,model.mesh_transform_matrix_array[i])
            end
        end
        min, max = position_table_bound(buff, min, max)
    end
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
    model.AABB = {
        min = vec3(0),
        max = vec3(0),
        owner = 0,
        live = true
    }
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

function V_PHYSICS.construct_AABB(object, mi, ma)
    object.AABB = {
        min = mi,
        max = ma,
        owner = object,
        live = true
    }
    table.insert(V_PHYSICS.AABB_vector, object.AABB)
end

function V_PHYSICS.test_AABB_collision(a, b)
    if a.max.x < b.min.x or a.min.x > b.max.x then return false end
    if a.max.y < b.min.y or a.min.y > b.max.y then return false end
    if a.max.z < b.min.z or a.min.z > b.max.z then return false end
    return true
end

local function cmp_AABB(a, b)
    return a.min[V_PHYSICS.SORT_AXIS] < b.min[V_PHYSICS.SORT_AXIS]
end

function V_PHYSICS.sweep_and_prune(block)
    table.sort(block.AABB_vector, cmp_AABB)
    local s, s2, v, l = vec3(0), vec3(0), vec3(0), #block.AABB_vector
    for i,v in ipairs(block.AABB_vector) do
        s = s + (v.min + v.max)/2
        s2 = s2 + (v.min + v.max)^2/4
        for j = i + 1, l do
            if v.min[V_PHYSICS.SORT_AXIS] < block.AABB_vector[j][V_PHYSICS.SORT_AXIS] then
                break
            end
            if V_PHYSICS.test_AABB_collision(v, block.AABB_vector[j]) then
                block[j].owner:collision(block.AABB_vector[j])
            end
        end
    end
    v = (s2 - vec3(s.x^2,s.y^2,s.z^2)/l)/l
    V_PHYSICS.SORT_AXIS = "x"
    if v.y > v.x then V_PHYSICS.SORT_AXIS = "y" end
    if v.z > v[V_PHYSICS.SORT_AXIS] then V_PHYSICS.SORT_AXIS = "z" end
end

function V_PHYSICS.setup(camera, projection_parameters)
    
end

function V_PHYSICS.update()

end

function V_PHYSICS.stop()

end