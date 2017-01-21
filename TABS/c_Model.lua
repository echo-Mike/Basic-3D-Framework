--[[
    DESCRIPTION: 
        Module contains implementation of model class
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.3:
        BUGSCLOSED:
            D756D3B7
    v_0.0.2:
        NEW:
            New description of matrix, mesh, vec2, vec3, vec4 variables types as Codea:Type in DESCRIPTION and NAMESPACE sections
            Local functions place in file (after dependencies check)
        CREATED:
            Codea classes dependencies check
            An error to handle Codea classes missing: 
                NAME: errors.NO_CODEA = 2
                ERROR_STRING: "Runing without Codea classes"
            BUGLIST section
    v_0.0.1: 
        CREATED: 
            Error facility:
                void C_MODEL.error(const float error_type, ...)
            model class definition:
                model init(table t)
                void draw(void)
                void add_mesh(Codea:mesh[nil] mes, Codea:matrix[nil] mesh_transform_matrix, int position)
                void swap_meshes(int m1, int m2)
                Codea:mesh,Codea:matrix remove_mesh(int position)
                void v_translate(Codea:vec3[Codea:vec4] dv)
                void moveto(float X, float Y, float Z)
                void v_moveto(Codea:vec3[Codea:vec4] v)
                void rotate(float deg, float X, float Y, float Z)
                void global_rotate(float deg, float X, float Y, float Z)
                void global_rotation(float deg, float X, float Y, float Z)
                void scale(float x, float y, float z)
                void clear_transform_matrix(void)
                void setColors(uint8 r, uint8 g, uint8 b)
                void mesh_translate(int n, float dx, float dy, float dz)
                void mesh_v_translate(Codea:vec4 dv)
                void mesh_moveto(int n, float X, float Y, float Z)
                void mesh_v_moveto(Codea:vec4 v)
                void mesh_rotate(int n, float deg, float X, float Y, float Z)
                void mesh_model_rotation(int n, float deg, float X, float Y, float Z)
                void mesh_scale(int n, float x, float y, float z)
                void mesh_clear_transform_matrix(int n)
                void mesh_setColors(int n, uint8 r, uint8 g, uint8 b)
                void mesh_relative_translate(int base, int n, float dx, float dy, float dz)
                void mesh_relative_moveto(int base, int n, float X, float Y, float Z)
                void mesh_relative_rotate(int base, int n, float deg, float X, float Y, float Z)
                void clear_all_transformations(void)
                Codea:mesh[,table] bake(boolean return_data)
                int in_mtma_range(T[number] n)
            Other local functions:
                void append_tables(table container, table t)
                void append_data(table container, T data, float times)
                void append_position(table container, table t, Codea:matrix mat)
                Codea:vec3 C_MODEL.v3mp(Codea:vec3 v, Codea:matrix m)
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable C_MODEL
            class model
                model init(table t)
                void draw(void)
                void add_mesh(Codea:mesh[nil] mes, Codea:matrix[nil] mesh_transform_matrix, int position)
                void swap_meshes(int m1, int m2)
                Codea:mesh,Codea:matrix remove_mesh(int position)
                void v_translate(Codea:vec3[Codea:vec4] dv)
                void moveto(float X, float Y, float Z)
                void v_moveto(Codea:vec3[Codea:vec4] v)
                void rotate(float deg, float X, float Y, float Z)
                void global_rotate(float deg, float X, float Y, float Z)
                void global_rotation(float deg, float X, float Y, float Z)
                void scale(float x, float y, float z)
                void clear_transform_matrix(void)
                void setColors(uint8 r, uint8 g, uint8 b)
                void mesh_translate(int n, float dx, float dy, float dz)
                void mesh_v_translate(Codea:vec4 dv)
                void mesh_moveto(int n, float X, float Y, float Z)
                void mesh_v_moveto(Codea:vec4 v)
                void mesh_rotate(int n, float deg, float X, float Y, float Z)
                void mesh_model_rotation(int n, float deg, float X, float Y, float Z)
                void mesh_scale(int n, float x, float y, float z)
                void mesh_clear_transform_matrix(int n)
                void mesh_setColors(int n, uint8 r, uint8 g, uint8 b)
                void mesh_relative_translate(int base, int n, float dx, float dy, float dz)
                void mesh_relative_moveto(int base, int n, float X, float Y, float Z)
                void mesh_relative_rotate(int base, int n, float deg, float X, float Y, float Z)
                void clear_all_transformations(void)
                Codea:mesh[,table] bake(boolean return_data)
                int in_mtma_range(T[number] n)
        LOCAL:
            variable errors
            void append_tables(table container, table t)
            void append_data(table container, T data, int times)
            void append_position(table container, table t, Codea:matrix mat)
        WEAK:
            Codea:vec3 C_MODEL.v3mp(Codea:vec3 v, Codea:matrix m)
]]
--[[
    TODOLIST:
        1:  
]]
--[[
    BUGLIST:
        D756D3B7: Close
]]
--[[
    DEPENDENCIES(STRONG):
        Codea:matrix()
        Codea:mesh()
        Codea:vec2()
        Codea:vec3()
        Codea:vec4()
]]

--Module and module internal functions declaration
if C_MODEL then
    error("C_Model: C_MODEL variable is already occupied as: "..tostring(C_MODEL))
end

C_MODEL = {
    loaded = true,
    f_utils_loaded = true, 
    --[[
        Error facility behavior qualifier: 
        0:raise lua error
        1:print error messege to stdout
        2:print error messege to stderr
    ]]
    no_errors = 0,
    version = "0.0.3"
}

--Error declaration based on Codea autofill specifics
local errors = {}
errors.INITIAL_SIZE = 0
errors.MTMA_RANGE = 1
errors.NO_CODEA = 2

--Error facility declaration
function C_MODEL.error(error_type, ...)
    local t, s = {...}, "c_Model:"
    if error_type == errors.INITIAL_SIZE then
        s = s.."#meshes: "..tostring(t[1]).." and #mesh_transform_matrix_array: "..tostring(t[2]).." aren't equal"
    elseif error_type == errors.MTMA_RANGE then
        s = s.."Invalid mesh_transform_matrix_array key: "..tostring(t[1])
    elseif error_type == errors.NO_CODEA then
        s = s.."Runing without Codea classes"
    else
        s = s.."Unknown error type"
	end
    if C_MODEL.no_errors == 1 then
        print(s)
    elseif C_MODEL.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--STRONG:
--Check Codea classes loaded
if (not mesh) or (not matrix) or (not vec2) or (not vec3) or (not vec4) then
    C_MODEL.loaded = false
    C_MODEL.error(errors.NO_CODEA)
end

--WEAK:
--Check f_Utils module loaded
if (not F_UTILS) and (not F_UTILS.loaded) then
    C_MODEL.f_utils_loaded = false
    --Vector (vec3) to matrix multiplication with w component normalisation
    C_MODEL.v3mp = function(v, m)
        local res = vec4(0)
        res.x = v.x*m[1]+v.y*m[5]+v.z*m[ 9]+m[13]
        res.y = v.x*m[2]+v.y*m[6]+v.z*m[10]+m[14]
        res.z = v.x*m[3]+v.y*m[7]+v.z*m[11]+m[15]
        res.w = v.x*m[4]+v.y*m[8]+v.z*m[12]+m[16]
        return vec3(res.x, res.y, res.z)/res.w
    end
end

--Local functions

--Append table "t" to table "container"
local function append_tables(container, t)
    for _,v in pairs(t) do
        table.insert(container, v)
    end
end

--Append userdata "data" to table "container" "times" times
local function append_data(container, data, times)
    if times > 0 then
        for i = 1,times do
            table.insert(container, data)
        end
    end
end

--Special function for vertices data conversion in bake function
local function append_position(container, t, mat)
    if C_MODEL.f_utils_loaded then
        for _,v in pairs(t) do
            table.insert(container, v3mp(v,mat))
        end
    else
        for _,v in pairs(t) do
            table.insert(container, C_MODEL.v3mp(v, mat))
        end
    end
end

--model class definition

model = class()

--This class uses underscores names notation

function model:init(t)
    local t = t or {}
    self.meshes = {}
    if type(t.meshes) == "table" then
        self.meshes = t.meshes
    end
    self.model_transform_matrix = t.model_transform_matrix or matrix()
    self.mesh_transform_matrix_array = {}
    if type(t.mesh_transform_matrix_array) == "table" then
        if #self.meshes ~= #t.mesh_transform_matrix_array then
            C_MODEL.error(errors.INITIAL_SIZE, #self.meshes, #t.mesh_transform_matrix_array)
        end
        self.mesh_transform_matrix_array = t.mesh_transform_matrix_array
    else
        if self.meshes and #self.meshes > 0 then
            for _,_ in pairs(self.meshes) do
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
function model:bake(return_data)
    local vert, col, tc, norm = {}, {}, {}, {}
    local e = 1
    local datatable = {}
    local buff, exist = nil, nil
    for i,v in ipairs(self.meshes) do
        table.insert(datatable, e)
        e = e + v.size
        exist, buff = pcall(v.buffer,v,"position")
        if exist and buff then
            append_position(vert, buff:get(), self.mesh_transform_matrix_array[i])
        else
            append_data(vert, vec3(0,0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"color")
        if exist and buff then
            append_tables(col, buff:get())
        else
            appendData(col, vec3(0,0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"texCoords")
        if exist and buff then
            append_tables(tc, buff:get())
        else
            append_data(tc, vec2(0,0), v.size)
        end
        exist, buff = pcall(v.buffer,v,"normals")
        if exist and buff then
            append_tables(norm, buff:get())
        else
            append_data(norm, vec3(0,0,0), v.size)
        end
    end
    local m = mesh()
    m.vertices = vert
    m.colors = col
    m.texCoords = tc
    m.normals = norm
    if return_data then
        return m, datatable
    else
        return m
    end
end

--[[ 
    Check index n to be in [1, #self.mesh_transform_matrix_array]; 
    mtma stends for mesh_transform_matrix_array;
    Raises lua error
]]
function model:in_mtma_range(n)
    if not n or n > #self.mesh_transform_matrix_array or n < 1 then
        C_MODEL.error(errors.MTMA_RANGE, n)
    end
    return n
end
