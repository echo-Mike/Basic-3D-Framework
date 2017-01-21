--[[
    DESCRIPTION: 
        Module contains functions that generate 3D primitives: 
            UV-sphere; 
            Cubic-sphere; 
            Cylinder; 
            Surface; 
            Cube.
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.2:
        BUGSCLOSED:
            B7EFCF58
    v_0.0.1: 
        CREATED:
            Error facility:
                void F_MESH_GEN.error(const float error_type, ...)
            Functions:
                Codea:mesh makeUVSphere(float rad, int Lsteps, int Asteps, boolean normals_in)
                Codea:mesh makeCubeSphere(float rad, int step, boolean normals_in)
                Codea:mesh makeCylinder(float rad, float heigh, int steps)
                Codea:mesh makeSurface(Codea:vec3 center)
                Codea:mesh makeCube(float s)
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable F_MESH_GEN
            Codea:mesh makeUVSphere(float rad, int Lsteps, int Asteps, boolean normals_in)
            Codea:mesh makeCubeSphere(float rad, int step, boolean normals_in)
            Codea:mesh makeCylinder(float rad, float heigh, int steps)
            Codea:mesh makeSurface(Codea:vec3 center)
            Codea:mesh makeCube(float s)
        LOCAL:
            variable errors   
]]
--[[
    TODOLIST:
        1: сделать функции генерации: 
            тор; 
            сфера из иксоаэдра; 
            сфера из тетраэдра; 
            сфера из октаэдра.
        2: добавить стандартную генерацию нормалей
        3: переписать функцию создания плоскости под возможность задавать её через указание нормали
        4: 
]]
--[[
    BUGLIST:
        B7EFCF58: Close
]]
--[[
    DEPENDENCIES(STRONG): 
        F_Utils:ivert(t, ...)
        Codea:mesh()
        Codea:vec3()
        Codea:vec4()
]]

--Module declaration
if F_MESH_GEN then
    print("f_Mesh_Gen: F_MESH_GEN variable is already occupied as: "..tostring(F_MESH_GEN))
end

F_MESH_GEN = {
    loaded = true,
    f_utils_loaded = true,
    --[[
        Error facility behavior qualifier: 
        0:raise lua error
        1:print error messege to stdout
        2:print error messege to stderr
    ]]
    no_errors = 0,
    version = "0.0.2"
}

--Error declaration based on Codea autofill specifics
local errors = {}
errors.NO_F_UTILS = 0
errors.NO_CODEA = 1

--Error facility declaration
function F_MESH_GEN.error(error_type, ...)
    local t, s = {...}, "f_Mesh_Gen:"
    if error_type == errors.NO_F_UTILS then
        s = s.."Module f_Utils needed"
    elseif error_type == errors.NO_CODEA then
        s = s.."Runing without Codea classes"
    else
        s = s.."Unknown error type"
	end
    if F_MESH_GEN.no_errors == 1 then
        print(s)
    elseif F_MESH_GEN.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--STRONG:
--Check Codea classes loaded
if (not mesh) or (not vec3) or (not vec4) then
    F_MESH_GEN.loaded = false
    F_MESH_GEN.error(errors.NO_CODEA)
end

require("f_Utils")
--Check f_Utils module loaded
if not F_UTILS.loaded then
    F_MESH_GEN.loaded = false
    F_MESH_GEN.f_utils_loaded = false
    F_MESH_GEN.error(errors.NO_F_UTILS)
end

--Functions definition

--Create UV-sphere
function makeUVSphere(rad, Lsteps, Asteps, normals_in)
    local cos,sin = math.cos, math.sin
    local dl = math.pi*2/Lsteps
    if Lsteps < 3 then dl = math.pi*2/3 end
    local da = math.pi/(Asteps+1)
    if Asteps < 1 then da = math.pi/2 end
    if normals_in then --clockwise rotation for OpenGL render
        dl = -dl
    end
    local top = vec3(0,1,0)
    local bot = -top
    local c = {}
    for i = 1, Asteps do
        for j = 1, Lsteps do
            table.insert(c, vec3(sin(i*da)*sin(j*dl), -cos(i*da), sin(i*da)*cos(j*dl)))
        end
    end
    local norm = {}
    for j = 1, Lsteps do--bottom
        if j == Lsteps then
            ivert(norm, bot, c[1], c[j])
        else
            ivert(norm, bot, c[j+1], c[j])
        end
    end
    for i = 0, Asteps-2 do--middle lanes
        for j = 1, Lsteps do
            if j == Lsteps then
                ivert(norm, c[Lsteps*i+j], c[Lsteps*i+1], c[Lsteps*(i+1)+1])
                ivert(norm, c[Lsteps*i+j], c[Lsteps*(i+1)+1], c[Lsteps*(i+1)+j])
            else
                ivert(norm, c[Lsteps*i+j], c[Lsteps*i+j+1], c[Lsteps*(i+1)+j+1])
                ivert(norm, c[Lsteps*i+j], c[Lsteps*(i+1)+j+1], c[Lsteps*(i+1)+j])
            end
        end
    end
    for j = 1, Lsteps do--top
        if j == Lsteps then
            ivert(norm, c[Lsteps*(Asteps-1)+j], c[Lsteps*(Asteps-1)+1], top)
        else
            ivert(norm, c[Lsteps*(Asteps-1)+j], c[Lsteps*(Asteps-1)+j+1], top)
        end
    end
    local m = mesh()
    local vert = {}
    for _,v in ipairs(norm) do
       table.insert(vert, rad*v)
    end
    if normals_in then
        for i,v in ipairs(norm) do
           norm[i] = -v
        end
    end
    m.normals = norm
    m.vertices = vert
    return m
end

--Create sphere from cube
function makeCubeSphere(rad, step, normals_in)
    local steps = math.floor(step)
    local p = {f={}, l={}, b={}, r={}, d={}, t={}}
    local vert = {f={}, l={}, b={}, r={}, d={}, t={}}
    local vertres = {} --storage of triangles
    local steplen, v = 1/steps, vec3(0)
    local appendTables = function(container, t) --append table "t" to table "container"
        for _,v in pairs(t) do
            table.insert(container, v)
        end
    end
    for i = 0,steps do
        for j = 0,steps do
            v = vec3(0.5, i*steplen-0.5, j*steplen-05) --generate point for front surface
            v = v*rad/v:len() --make vector lie on sphere surface
            table.insert(p.f, vec4(v.x,v.y,v.z,1))  --front
            table.insert(p.l, vec4(-v.z,v.y,v.x,1)) --left
            table.insert(p.b, vec4(-v.x,v.y,-v.z,1))--back
            table.insert(p.r, vec4(v.z,v.y,-v.x,1)) --right
            table.insert(p.d, vec4(v.y,-v.x,v.z,1)) --down
            table.insert(p.t, vec4(-v.y,v.x,v.z,1)) --top
        end
    end
    local a,b,c,d = 0,0,0,0
    --acb bcd for normals out
    --abc bdc for normals in
    for i = 0,step-1 do
        for j = 1,step do
            a = j + i * (steps+1)
            b = a + 1
            c = a + steps + 1
            d = c + 1
            for k,v in pairs(vert) do
                if normals_in then
                    ivert(v, p[k][a], p[k][b], p[k][c], p[k][b], p[k][d], p[k][c])
                else
                    ivert(v, p[k][a], p[k][c], p[k][b], p[k][b], p[k][c], p[k][d])
                end
            end
        end
    end
    appendTables(vertres, vert.f)
    appendTables(vertres, vert.l)
    appendTables(vertres, vert.b)
    appendTables(vertres, vert.r)
    appendTables(vertres, vert.d)
    appendTables(vertres, vert.t)
    local m = mesh()
    mvertices = vertres
    return m
end

--Create cylinder
function makeCylinder(rad, heigh, steps)
    local d,da = heigh/2, -math.pi*2/steps
    local c = {vec3(0,-d,0), vec3(0,d,0)}
    for i = 1, steps do
        table.insert(c, vec3(rad*math.cos(da*i), -d, rad*math.sin(da*i)))
        table.insert(c, vec3(rad*math.cos(da*i),  d, rad*math.sin(da*i)))
    end
    local vert = {}
    for i = 1, steps do 
        if i == steps then
            ivert(vert, c[1], c[2*i+1], c[3]) --top
            ivert(vert, c[2], c[4], c[2*i+2]) --bottom
            ivert(vert, c[2*i+1], c[2*i+2], c[3]) --face left
            ivert(vert, c[3], c[2*i+2], c[4]) --face right
        else
            ivert(vert, c[1], c[2*i+1], c[2*i+3]) --top
            ivert(vert, c[2], c[2*i+4], c[2*i+2]) --bottom
            ivert(vert, c[2*i+1], c[2*i+2], c[2*i+3]) --face left
            ivert(vert, c[2*i+3], c[2*i+2], c[2*i+4]) --face right
        end
    end
    local m = mesh()
    m.vertices = vert
    return m
end

--Create surface with length and width 100 in point "center", normal have same direction as y axis
function makeSurface(center)
    local c = {
        vec3(center.x-50, center.y, center.z-50),
        vec3(center.x+50, center.y, center.z-50),
        vec3(center.x+50, center.y, center.z+50),
        vec3(center.x-50, center.y, center.z+50)
    }
    local vert = {
        c[1], c[2], c[4],
        c[4], c[2], c[3]
    }
    local m = mesh()
    m.vertices = vert
    return m
end

--Create cube
function makeCube(s)
    local d=0.5*s
    local c = {
        vec3(-d, -d, d), -- Left bottom front black
        vec3( d, -d, d), -- Right bottom front blue
        vec3( d, d, d), -- Right top front cyan
        vec3(-d, d, d), -- Left top front green
        vec3(-d, -d, -d), -- Left bottom back red
        vec3( d, -d, -d), -- Right bottom back magenta
        vec3( d, d, -d), -- Right top back white
        vec3(-d, d, -d) -- Left top back yellow
    }
    local vert = {
        c[1], c[2], c[3], c[1], c[3], c[4], --Front 
        c[2], c[6], c[7], c[2], c[7], c[3], --Right 
        c[6], c[5], c[8], c[6], c[8], c[7], --Back 
        c[5], c[1], c[4], c[5], c[4], c[8], --Left 
        c[4], c[3], c[7], c[4], c[7], c[8], --Top 
        c[5], c[6], c[2], c[5], c[2], c[1]  --Bottom
    }
    local m = mesh()
    mvertices = vert
    return m
end
