--DESCRIPTION: Module contains implementation of model class 
--DEPENDENCIES(WEAK): F_Utils:vmp(v, m); F_Utils:v3to4(v); F_Utils:v4to3(v)

--Module and module internal functions declaration
if C_MODEL then
    error("C_Model: C_MODEL variable is already occupied as: "..tostring(C_MODEL))
end

C_MODEL = {
    loaded = true, 
    f_utils_loaded = true, 
    no_errors = false,       --Error facility behavior qualifier: false:raise lua error; true:print error messege
}

--Error declaration based on Codea autofill specifics
C_MODEL.errors = {}
C_MODEL.errors.INITIAL_SIZE = 0
C_MODEL.errors.MTMA_RANGE = 1

--Error facility declaration
C_MODEL.error = function(error_type, ...)
    local t, s = {...}, ""
    if error_type == C_MODEL.errors.INITIAL_SIZE then
        s = "C_Model:#meshes: "..tostring(t[1]).." and #mesh_transform_matrix_array: "..tostring(t[2]).." aren't equal"
    end
    if error_type == C_MODEL.errors.MTMA_RANGE then
        s = "C_Model:Invalid mesh_transform_matrix_array key: "..tostring(t[1])
    end
    if C_MODEL.no_errors then
        print(s)
    else
        error(s)
    end
end

--Append table "t" to table "container"
C_MODEL.append_tables = function(container, t)
    for _,v in pairs(t) do
        table.insert(container, v)
    end
end

--Append userdata "data" to table "container" "times" times
C_MODEL.append_data = function(container, data, times)
    if times > 0 then
        for i = 1,times do
            table.insert(container, data)
        end
    end
end

--Special function for vertices data conversion in bake function
C_MODEL.append_position = function(container, t, mat)
    if C_MODEL.f_utils_loaded then
        for _,v in pairs(t) do
            table.insert(container, v4to3(vmp(v3to4(v),mat)))
        end
    else
        for _,v in pairs(t) do
            table.insert(container, C_MODEL.apply_matrix(v, mat))
        end
    end
end

--Dependencies chesk
if not F_UTILS then
    C_MODEL.f_utils_loaded = false
    --Vector (vec3) to matrix multiplication with w component normalisation
    C_MODEL.apply_matrix = function(v, m)
        local res = vec4(0)
        res.x = v.x*m[1]+v.y*m[5]+v.z*m[ 9]+m[13]
        res.y = v.x*m[2]+v.y*m[6]+v.z*m[10]+m[14]
        res.z = v.x*m[3]+v.y*m[7]+v.z*m[11]+m[15]
        res.w = v.x*m[4]+v.y*m[8]+v.z*m[12]+m[16]
        return vec3(res.x, res.y, res.z)/res.w
    end
end

--model class definition
model = class()

--This class uses underscores names notation

function model:init(meshes, model_transform_matrix, mesh_transform_matrix_array, animations)
    self.meshes = {}
    if type(meshes) == "table" then
        self.meshes = meshes
    end
    if model_transform_matrix then
        self.model_transform_matrix = model_transform_matrix
    else
        self.model_transform_matrix = matrix()
    end
    self.mesh_transform_matrix_array = {}
    if type(mesh_transform_matrix_array) == "table" then
        if #meshes ~= #mesh_transform_matrix_array then
            C_MODEL.error(C_MODEL.errors.INITIAL_SIZE, #meshes, #mesh_transform_matrix_array)
        end
        self.mesh_transform_matrix_array = mesh_transform_matrix_array
    else
        if meshes then
            for _,_ in pairs(meshes) do
                table.insert(self.mesh_transform_matrix_array, matrix())
            end
        end
    end
end

--Draw model
function model:draw()
    pushMatrix()
    applyMatrix(self.model_transform_matrix)
    for k,v in pairs(self.meshes) do
        pushMatrix()
        if k<=#self.mesh_transform_matrix_array and self.mesh_transform_matrix_array[k] then
            applyMatrix(self.mesh_transform_matrix_array[k])
        end
        v:draw()
        popMatrix()
    end
    popMatrix()
end

--Meshes control functions

--Insert new mesh "mes" to model at position "position" with transformation matrix "mesh_transform_matrix"
function model:add_mesh(mes, mesh_transform_matrix, position)
    local pos = #self.meshes
    if type(position) == "number" then
        self:in_mtma_range(position)
        pos = position
    end
    if mes then
        table.insert(self.meshes, pos, mes)
    else
        table.insert(self.meshes, pos, mesh())
    end
    if mesh_transform_matrix then
        table.insert(self.mesh_transform_matrix_array, pos, mesh_transform_matrix)
    else
        table.insert(self.mesh_transform_matrix_array, pos, matrix())
    end
end

--Swap meshes number "m1" and "m2" in self.meshes 
function model:swap_meshes(m1, m2)
    self:in_mtma_range(m1)
    self:in_mtma_range(m2)
    local l, r = m1, m2
    if m1 > m2 then
        l, r = m2, m1
    elseif m1 == m2 then
        return
    end
    table.insert(self.meshes,l,table.remove(self.meshes, r))
    table.insert(self.mesh_transform_matrix_array,l,table.remove(self.mesh_transform_matrix_array, r))
    table.insert(self.meshes,r,table.remove(self.meshes, l+1))
    table.insert(self.mesh_transform_matrix_array,r,table.remove(self.mesh_transform_matrix_array, l+1))
end

--Remove mesh with position "position" from model, returns mesh and it's transformation matrix
function model:remove_mesh(position)
    local pos = #self.meshes
    if type(position) == "number" then
        self:in_mtma_range(position)
        pos = position
    end
    return table.remove(self.meshes, pos), table.remove(self.mesh_transform_matrix_array, pos)
end

--Model transformations

--Setup position in curent Model coordinates
function model:translate(dx,dy,dz)
    self.model_transform_matrix = self.model_transform_matrix:translate(dx,dy,dz)
end

--Vector version of the previous function
function model:v_translate(dv)
    self:translate(dv.x,dv.y,dv.z)
end

--Setup position in World coordinates
function model:moveto(X,Y,Z)
    self.model_transform_matrix[13]=0
    self.model_transform_matrix[14]=0
    self.model_transform_matrix[15]=0
    self.model_transform_matrix = self.model_transform_matrix * matrix():translate(X,Y,Z) 
end

--Vector version of the previous function
function model:v_moveto(v)
    self:moveto(v.x,v.y,v.z)
end

--Setup rotation in curent Model coordinates
function model:rotate(deg,X,Y,Z)
    self.model_transform_matrix = self.model_transform_matrix:rotate(deg,X,Y,Z)
end

--[[
    Rotate model around World axis
    Like model center is in (0,0,0)
    Preserve current rotation data
]]
function model:global_rotate(deg,X,Y,Z)
    local a = self.model_transform_matrix
    self.model_transform_matrix = self.model_transform_matrix*matrix():rotate(deg,X,Y,Z)
    self.mesh_transform_matrix_array[n][13] = a[13]
    self.mesh_transform_matrix_array[n][14] = a[14]
    self.mesh_transform_matrix_array[n][15] = a[15]
end

--[[
    Setup rotation in World coordinates
    Clear current rotation data
    Preserve translation data but clear scale data
]]
function model:global_rotation(deg,X,Y,Z)
    local a = self.model_transform_matrix
    self.model_transform_matrix = matrix():rotate(deg,X,Y,Z)
    self.model_transform_matrix[13] = a[13]
    self.model_transform_matrix[14] = a[14]
    self.model_transform_matrix[15] = a[15]
end

--[[
    Setup scale in curent Model coordinates
    This function is slow
]]
function model:scale(x,y,z)
    if (not y) and (not z) then
        self.model_transform_matrix = self.model_transform_matrix:scale(x,x,x)
        return
    end
    if not z then
        self.model_transform_matrix = self.model_transform_matrix:scale(x,y,1)
        return
    end
    self.model_transform_matrix = self.model_transform_matrix:scale(x,y,z)
end

--Clear model transform matrix
function model:clear_transform_matrix()
    self.model_transform_matrix = matrix()
end

--[[
    Set all mesh's vertices color to (r,g,b)
    Haven't got support for: alfa channel, color data type, grayscale value
]]
function model:setColors(r,g,b)
    for _,v in pairs(self.meshes) do
        v:setColors(r,g,b)
    end
end

--Individual mesh transformations. Use model center and axis as world center (0,0,0) and world axis (transformation in model basis)

--Setup position in current Mesh coordinates
function model:mesh_translate(n,dx,dy,dz)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n]:translate(dx,dy,dz)
end

--[[
    Vector version of the previous function
    Use dv.w as mesh index
]]
function model:mesh_v_translate(dv)
    self:translate(dv.w,dv.x,dv.y,dv.z)
end

--Setup position in current Model coordinates
function model:mesh_moveto(n,X,Y,Z)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n][13]=0
    self.mesh_transform_matrix_array[n][14]=0
    self.mesh_transform_matrix_array[n][15]=0
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * matrix():translate(X,Y,Z)
end

--[[
    Vector version of the previous function
    Use v.w as mesh index
]]
function model:mesh_v_moveto(v)
    self:mesh_moveto(v.w,v.x,v.y,v.z)
end

--Setup rotation in current Mesh coordinates
function model:mesh_rotate(n,deg,X,Y,Z)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n]:rotate(deg,X,Y,Z)
end

--[[
    Rotate mesh around Model axis
    Like mesh center is in (0,0,0)
    Preserve current rotation data
]]
function model:mesh_model_rotate(n,deg,X,Y,Z)
    self:in_mtma_range(n)
    local a = self.mesh_transform_matrix_array[n]
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * matrix():rotate(deg,X,Y,Z)
    self.mesh_transform_matrix_array[n][13] = a[13]
    self.mesh_transform_matrix_array[n][14] = a[14]
    self.mesh_transform_matrix_array[n][15] = a[15]
end

--[[
    Setup rotation in Model coordinates
    Clear current rotation data
    Preserve translation data but clear scale data
]]
function model:mesh_model_rotation(n,deg,X,Y,Z)
    self:in_mtma_range(n)
    local a = self.mesh_transform_matrix_array[n]
    self.mesh_transform_matrix_array[n] = matrix():rotate(deg,X,Y,Z)
    self.mesh_transform_matrix_array[n][13] = a[13]
    self.mesh_transform_matrix_array[n][14] = a[14]
    self.mesh_transform_matrix_array[n][15] = a[15]
end

--[[
    Setup scale in curent Mesh coordinates
    This function is slow
]]
function model:mesh_scale(n,x,y,z)
    self:in_mtma_range(n)
    if (not y) and (not z) then
        self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n]:scale(x,x,x)
        return
    end
    if not z then
        self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n]:scale(x,y,1)
        return
    end
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n]:scale(x,y,z)
end

--Clear mesh transform matrix
function model:mesh_clear_transform_matrix(n)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = matrix()
end

--[[
    Set mesh's vertices color to (r,g,b)
    Haven't got support for: alfa channel, color data type, grayscale value
]]
function model:mesh_setColors(n,r,g,b)
    self:in_mtma_range(n)
    self.meshes[n]:setColors(r,g,b)
end

--[[
    Individual mesh transformations relative to base mesh. 
    Use base mesh center and axis as world center (0,0,0) and world axis (transformation in base mesh basis)
]]

--Translate mesh in base mesh basis
function model:mesh_relative_translate(base,n,dx,dy,dz)
    self:in_mtma_range(base)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]:inverse()
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * matrix():translate(dx,dy,dz)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]
end

--Setup position in base Mesh basis
function model:mesh_relative_moveto(base,n,x,y,z)
    self:in_mtma_range(base)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]:inverse()
    self.mesh_transform_matrix_array[n][13]=0
    self.mesh_transform_matrix_array[n][14]=0
    self.mesh_transform_matrix_array[n][15]=0
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * matrix():translate(x,y,z)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]
end

--Setup rotation in base Mesh basis
function model:mesh_relative_rotate(base,n,deg,X,Y,Z)
    self:in_mtma_range(base)
    self:in_mtma_range(n)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]:inverse()
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * matrix():rotate(deg,X,Y,Z)
    self.mesh_transform_matrix_array[n] = self.mesh_transform_matrix_array[n] * self.mesh_transform_matrix_array[base]
end

--Clear all transform matrix
function model:clear_all_transformations()
    self.model_transform_matrix = matrix()
    self.mesh_transform_matrix_array = {}
    if self.meshes then
        for _,_ in pairs(self.meshes) do
            table.insert(self.mesh_transform_matrix_array, matrix())
        end
    end
end

--[[
    Create one mesh model from current model
    by applying all mesh transform matrix 
    and sending data to one mesh
    Haven't got support for: texture, shader
    Output: mesh, datatable
    datatabel content(k,v): (i,satrt index of i mesh in new mesh arrays)
]]
function model:bake()
    local vert, col, tc, norm = {}, {}, {}, {}
    local e = 1
    local datatable = {}
    local buff, exist = nil, nil
    for i,v in ipairs(self.meshes) do
        table.insert(datatable, e)
        e = e + v.size
        exist, buff = pcall(v.buffer,v,"position")
        if exist and buff then
            C_MODEL.append_position(vert, buff:get(), self.mesh_transform_matrix_array[i])
        else
            C_MODEL.append_data(vert, vec3(0,0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"color")
        if exist and buff then
            C_MODEL.append_tables(col, buff:get())
        else
            appendData(col, vec3(0,0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"texCoords")
        if exist and buff then
            C_MODEL.append_tables(tc, buff:get())
        else
            C_MODEL.append_data(tc, vec2(0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"normals")
        if exist and buff then
            C_MODEL.append_tables(norm, buff:get())
        else
            C_MODEL.append_data(norm, vec3(0,0,0), v.size)
        end
    end
    local m = mesh()
    m.vertices = vert
    m.colors = col
    m.texCoords = tc
    m.normals = norm
    return m, datatable
end

--[[ 
    Check index n to be in [1, #self.mesh_transform_matrix_array]; 
    mtma stends for mesh_transform_matrix_array;
    Raises lua error
]]
function model:in_mtma_range(n)
    if not n or n > #self.mesh_transform_matrix_array or n < 1 then
        C_MODEL.error(C_MODEL.errors.MTMA_RANGE, n)
    end
    return n
end
