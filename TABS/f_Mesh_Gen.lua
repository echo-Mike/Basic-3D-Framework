--[[
    DESCRIPTION: 
        Module contains functions that generate 3D primitives: 
            UV-sphere; 
            Cubic-sphere; 
            Cylinder; 
            Surface; 
            Cube;
            Octahedron;
            Tetrahedron;
            Icosahedron;
            Torus.
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.3:
        UPDATED:
            Functions names simplification:
                makeUVSphere => uvSphere
                makeCubeSphere => cubeSphere
                makeCylinder => cylinder
                makeSurface => surface
                makeCube => cube
            Codea:mesh surface(Codea:vec3 center, float size)
                New parametr: 
                    float size
            Codea:mesh cube(float size, boolean normals_type, boolean normals_in)
                New parameters:
                    boolean normals_type
                    boolean normals_in
            New informative functions description
        CREATED:
            Functions:
                Codea:mesh octahedron(float rad, boolean normals_type, boolean normals_in)
                Codea:mesh tetrahedron(float rad, boolean normals_type, boolean normals_in)
                Codea:mesh icosahedron(float rad, boolean normals_type, boolean normals_in)
                Codea:mesh torus(float rad, float radin, int radsteps, int steps)
                void subdivide(Codea:mesh m, boolean method)
                table calculateNormals(table array, boolean normals_in)
                void tosphere(Codea:mesh m, float rad)
            All meshes now created with normals
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
            Codea:mesh uvSphere(float rad, int Lsteps, int Asteps, boolean normals_in)
            Codea:mesh cubeSphere(float rad, int step, boolean normals_in)
            Codea:mesh cylinder(float rad, float heigh, int steps)
            Codea:mesh surface(Codea:vec3 center, float size)
            Codea:mesh cube(float size, boolean normals_type, boolean normals_in)
            Codea:mesh octahedron(float rad, boolean normals_type, boolean normals_in)
            Codea:mesh tetrahedron(float rad, boolean normals_type, boolean normals_in)
            Codea:mesh icosahedron(float rad, boolean normals_type, boolean normals_in)
            Codea:mesh torus(float rad, float radin, int radsteps, int steps)
            void subdivide(Codea:mesh m, boolean method)
            table calculateNormals(table array, boolean normals_in)
            void tosphere(Codea:mesh m, float rad)
        LOCAL:
            variable errors   
]]
--[[
    TODOLIST:
        1:  
]]
--[[
    BUGLIST:
        B7EFCF58: Close
        DAED8CD8: Open
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
    version = "0.0.3"
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

--require("f_Utils") --Commented because it raises Code internal error
--Check f_Utils module loaded
if not F_UTILS.loaded then
    F_MESH_GEN.loaded = false
    F_MESH_GEN.f_utils_loaded = false
    F_MESH_GEN.error(errors.NO_F_UTILS)
end

--Functions definition

--[[
    Create UV-sphere
    rad - sphere radius
    Lsteps - longitude steps, 3 min
    Asteps - altitude steps between top and bottom point, 2 min 
    normals in - if true: generate triangles and normals towards center of sphere
]]
function uvSphere(rad, Lsteps, Asteps, normals_in)
    local cos,sin = math.cos, math.sin
    local dl = math.pi*2/Lsteps or math.pi*2/3
    if Lsteps < 3 then dl = math.pi*2/3 end
    local da = math.pi/(Asteps+1) or math.pi/2
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

--[[
    Create sphere from cube
    rad - sphere radius
    steps - divide initial cube surfaces into step*step size grid
    normals in - if true: generate triangles and normals towards center of sphere
]]
function cubeSphere(rad, step, normals_in)
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
            v = vec3(0.5, i*steplen-0.5, j*steplen-0.5) --generate point for front surface
            v = v*rad/v:len() --make vector lie on sphere surface
            table.insert(p.f, vec3(v.x,v.y,v.z))  --front
            table.insert(p.l, vec3(-v.z,v.y,v.x)) --left
            table.insert(p.b, vec3(-v.x,v.y,-v.z))--back
            table.insert(p.r, vec3(v.z,v.y,-v.x)) --right
            table.insert(p.d, vec3(v.y,-v.x,v.z)) --down
            table.insert(p.t, vec3(-v.y,v.x,v.z)) --top
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
    local norm = {}
    for _,v in ipairs(vertres) do
        if normals_in then
            table.insert(norm, -v:normalize())
        else
            table.insert(norm, v:normalize())
        end
    end
    local m = mesh()
    m.vertices = vertres
    m.normals = norm
    return m
end

--[[
    Create cylinder
    rad - cylinder radius
    heigh - cylinder heigh
    steps - count of side surfaces
]]
function cylinder(rad, heigh, steps)
    local d = heigh/2
    local da = math.pi*2/steps
    local top = vec3(0,d,0)
    local bot = -top
    local c ={}
    for i = 1,steps do
        table.insert(c, vec3(rad*math.sin(da*i), -d, rad*math.cos(da*i))) --bottom
        table.insert(c, vec3(rad*math.sin(da*i),  d, rad*math.cos(da*i))) --top
    end
    local vert = {}
    for i = 1,steps do
        if i == steps then
            ivert(vert, c[i*2-1], bot, c[1])    --bottom
            ivert(vert, c[i*2-1], c[2], c[i*2]) --face left
            ivert(vert, c[i*2-1], c[1], c[2])   --face right
            ivert(vert, c[i*2], c[2], top)      --top
        else
            ivert(vert, c[i*2-1], bot, c[i*2+1])      --bottom
            ivert(vert, c[i*2-1], c[i*2+2], c[i*2])   --face left
            ivert(vert, c[i*2-1], c[i*2+1], c[i*2+2]) --face right
            ivert(vert, c[i*2], c[i*2+2], top)        --top
        end
    end
    local norm = {}
    local a,b = 0,0
    local c,d = vec3(0,-1,0), vec3(0,1,0)
    for i = 1,steps do
        a = vec3(math.sin(da*i), 0, math.cos(da*i))
        b = vec3(math.sin(da*i+da), 0, math.cos(da*i+da))
        ivert(norm, c, c, c) --bottom
        ivert(norm, a, b, a) --face left
        ivert(norm, a, b, b) --face right
        ivert(norm, d, d, d) --top
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Create surface 
    size - length and width
    center - center point 
    normal have same direction as y axis
]]
function surface(center, size)
    local center = center or vec3(0,0,0)
    local d = size/2 or 50
    local c = {
        vec3(center.x-d, center.y, center.z-d),
        vec3(center.x+d, center.y, center.z-d),
        vec3(center.x+d, center.y, center.z+d),
        vec3(center.x-d, center.y, center.z+d)
    }
    local vert = {
        c[1], c[4], c[2],
        c[4], c[3], c[2]
    }
    local norm = {
        vec3(0,1,0), vec3(0,1,0), vec3(0,1,0),
        vec3(0,1,0), vec3(0,1,0), vec3(0,1,0)
    }
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Create cube
    if normals_type then 
        make normals pointed from center of cube 
    else 
        normals is a normals to surfaces of cube
    if normals_in then
        revers direction of normals
]]
function cube(size, normals_type, normals_in)
    local d=0.5*size
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
    local vert = {}
    if normals_in then
        vert = {
            c[1], c[3], c[2], c[1], c[4], c[3], --Front 
            c[2], c[7], c[6], c[2], c[3], c[7], --Right 
            c[6], c[8], c[5], c[6], c[7], c[8], --Back 
            c[5], c[4], c[1], c[5], c[8], c[4], --Left 
            c[4], c[7], c[3], c[4], c[8], c[7], --Top 
            c[5], c[2], c[6], c[5], c[1], c[2]  --Bottom
        }
        
    else
        vert = {
            c[1], c[2], c[3], c[1], c[3], c[4], --Front 
            c[2], c[6], c[7], c[2], c[7], c[3], --Right 
            c[6], c[5], c[8], c[6], c[8], c[7], --Back 
            c[5], c[1], c[4], c[5], c[4], c[8], --Left 
            c[4], c[3], c[7], c[4], c[7], c[8], --Top 
            c[5], c[6], c[2], c[5], c[2], c[1]  --Bottom
        }
    end
    local norm = {}
    if normals_type then
        for _,v in ipairs(vert) do
            if normals_in then
                table.insert(norm, -v:normalize())
            else
                table.insert(norm, v:normalize())
            end
        end
    else
        norm = calculateNormals(vert, normals_in)
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end


--[[
    Create octahedron
    if normals_type then 
        make normals pointed from center of octahedron 
    else 
        normals is a normals to surfaces of octahedron
    if normals_in then
        revers direction of normals
]]
function octahedron(rad, normals_type, normals_in)
    local c = {
        vec3(0,-rad,0), --bottom
        vec3(0,0,rad), --front +z
        vec3(rad,0,0), --right +x
        vec3(0,0,-rad), --back
        vec3(-rad,0,0), --left
        vec3(0,rad,0) --top +y
    }
    local vert = {}
    if normals_in then
        vert = {
            c[1], c[2], c[3],
            c[1], c[3], c[4],
            c[1], c[4], c[5],
            c[1], c[5], c[2],
            c[6], c[3], c[2],
            c[6], c[4], c[3],
            c[6], c[5], c[4],
            c[6], c[2], c[5]
        }
    else
        vert = {
            c[1], c[3], c[2],
            c[1], c[4], c[3],
            c[1], c[5], c[4],
            c[1], c[2], c[5],
            c[6], c[2], c[3],
            c[6], c[3], c[4],
            c[6], c[4], c[5],
            c[6], c[5], c[2]
        }
    end
    local norm = {}
    if normals_type then
        for _,v in ipairs(vert) do
            if normals_in then
                table.insert(norm, -v:normalize())
            else
                table.insert(norm, v:normalize())
            end
        end
    else
        norm = calculateNormals(vert, normals_in)
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Create tetrahedron
    if normals_type then 
        make normals pointed from center of tetrahedron 
    else 
        normals is a normals to surfaces of tetrahedron
    if normals_in then
        revers direction of normals
]]
function tetrahedron(rad, normals_type, normals_in)
    local tetrahedralAngle = math.pi * 109.4712 / 180;
    local segmentAngle = math.pi * 2 / 3;
    local currentAngle = 0;
    local c = {vec3(0,rad,0)}
    for i = 1,3 do
        table.insert(c, vec3(   rad * math.sin(currentAngle) * math.sin(tetrahedralAngle),
                                rad * math.cos(tetrahedralAngle),
                                rad * math.cos(currentAngle) * math.sin(tetrahedralAngle)))
        currentAngle = currentAngle + segmentAngle
    end
    local vert = {}
    if normals_in then
        vert = {
            c[1], c[3], c[2],
            c[2], c[3], c[4],
            c[1], c[4], c[3],
            c[1], c[2], c[4]
        }
    else
        vert = {
            c[1], c[2], c[3],
            c[2], c[4], c[3],
            c[1], c[3], c[4],
            c[1], c[4], c[2]
        }
    end
    local norm = {}
    if normals_type then
        for _,v in ipairs(vert) do
            if normals_in then
                table.insert(norm, -v:normalize())
            else
                table.insert(norm, v:normalize())
            end
        end
    else
        norm = calculateNormals(vert, normals_in)
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Create icosahedron
    if normals_type then 
        make normals pointed from center of icosahedron 
    else 
        normals is a normals to surfaces of icosahedron
    if normals_in then
        revers direction of normals
]]
function icosahedron(rad, normals_type, normals_in)
    local magicAngle = math.pi * 26.565/180;
    local segmentAngle = math.pi * 72 / 180;
    local currentAngle = 0;
    local c = {vec3(0, rad, 0)}
    for i = 1,5 do
        table.insert(c, vec3(   rad * math.sin(currentAngle) * math.cos(magicAngle),
                                rad * math.sin(magicAngle),
                                rad * math.cos(currentAngle) * math.cos(magicAngle)))
        currentAngle = currentAngle + segmentAngle
    end
    currentAngle = math.pi * 36/180;
    for i = 6,10 do
        table.insert(c, vec3(   rad * math.sin(currentAngle) * math.cos(-magicAngle),
                                rad * math.sin(-magicAngle),
                                rad * math.cos(currentAngle) * math.cos(-magicAngle)))
        currentAngle = currentAngle + segmentAngle
    end
    table.insert(c, vec3(0,-rad,0))
    local vert = {}
    if normals_in then
        vert = {
            c[1], c[3], c[2],
            c[1], c[4], c[3],
            c[1], c[5], c[4],
            c[1], c[6], c[5],
            c[1], c[2], c[6],
            c[12], c[7], c[8],
            c[12], c[8], c[9],
            c[12], c[9], c[10],
            c[12], c[10], c[11],
            c[12], c[11], c[7],
            c[3], c[7], c[2],
            c[4], c[8], c[3],
            c[5], c[9], c[4],
            c[6], c[10], c[5],
            c[2], c[11], c[6],
            c[7], c[3], c[8],
            c[8], c[4], c[9],
            c[9], c[5], c[10],
            c[10], c[6], c[11],
            c[11], c[2], c[7]
        }
    else
        vert = {
            c[1], c[2], c[3],
            c[1], c[3], c[4],
            c[1], c[4], c[5],
            c[1], c[5], c[6],
            c[1], c[6], c[2],
            c[12], c[8], c[7],
            c[12], c[9], c[8],
            c[12], c[10], c[9],
            c[12], c[11], c[10],
            c[12], c[7], c[11],
            c[3], c[2], c[7],
            c[4], c[3], c[8],
            c[5], c[4], c[9],
            c[6], c[5], c[10],
            c[2], c[6], c[11],
            c[7], c[8], c[3],
            c[8], c[9], c[4],
            c[9], c[10], c[5],
            c[10], c[11], c[6],
            c[11], c[7], c[2]
        }
    end
    local norm = {}
    if normals_type then
        for _,v in ipairs(vert) do
            if normals_in then
                table.insert(norm, -v:normalize())
            else
                table.insert(norm, v:normalize())
            end
        end
    else
        norm = calculateNormals(vert, normals_in)
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Create torus 
    rad - "work" radius of torus
    radin - radius of torus tube
    radsteps - count of "work" radius steps
    steps - count of tube steps
]]
function torus(rad, radin, radsteps, steps)
    local rad = rad or 100
    local radin = radin or 20
    local radsteps = radsteps or 10
    if radsteps < 3 then radsteps = 3 end
    local steps = steps or 10
    if steps < 3 then steps = 3 end
    local dia = -math.pi*2/steps
    local dea = math.pi*2/radsteps
    local c = {}
    local n = {}
    for i = 0,radsteps-1 do
        for j = 0,steps-1 do
            table.insert(c, vec3(   math.sin(dea*i)*(rad+radin*math.cos(dia*j)), 
                                    radin*math.sin(dia*j), 
                                    math.cos(dea*i)*(rad+radin*math.cos(dia*j))))
            table.insert(n, vec3(math.sin(dea*i)*math.cos(dia*j), 
                                    math.sin(dia*j), 
                                    math.cos(dea*i)*math.cos(dia*j)))
        end
    end
    local vert = {}
    local norm = {}
    for i = 0,radsteps-1 do
        if i == radsteps-1 then
            for j = 0,steps-1 do
                if j == steps-1 then
                    ivert(vert, c[i*steps+j+1], c[1], c[j+1])
                    ivert(vert, c[i*steps+j+1], c[i*steps+1], c[1])
                    ivert(norm, n[i*steps+j+1], n[1], n[j+1])
                    ivert(norm, n[i*steps+j+1], n[i*steps+1], n[1])
                else
                    ivert(vert, c[i*steps+j+1], c[j+2], c[j+1])
                    ivert(vert, c[i*steps+j+1], c[i*steps+j+2], c[j+2])
                    ivert(norm, n[i*steps+j+1], n[j+2], n[j+1])
                    ivert(norm, n[i*steps+j+1], n[i*steps+j+2], n[j+2])
                end
            end
        else
            for j = 0,steps-1 do
                if j == steps-1 then
                    ivert(vert, c[i*steps+j+1], c[(i+1)*steps+1], c[(i+1)*steps+j+1])
                    ivert(vert, c[i*steps+j+1], c[i*steps+1], c[(i+1)*steps+1])
                    ivert(norm, n[i*steps+j+1], n[(i+1)*steps+1], n[(i+1)*steps+j+1])
                    ivert(norm, n[i*steps+j+1], n[i*steps+1], n[(i+1)*steps+1])
                else
                    ivert(vert, c[i*steps+j+1], c[(i+1)*steps+j+2], c[(i+1)*steps+j+1])
                    ivert(vert, c[i*steps+j+1], c[i*steps+j+2], c[(i+1)*steps+j+2])
                    ivert(norm, n[i*steps+j+1], n[(i+1)*steps+j+2], n[(i+1)*steps+j+1])
                    ivert(norm, n[i*steps+j+1], n[i*steps+j+2], n[(i+1)*steps+j+2])
                end
            end
        end
    end
    local m = mesh()
    m.vertices = vert
    m.normals = norm
    return m
end

--[[
    Subdivide every triangle in mesh to 3 or 4 triangles 
    if method then
        by central point (1 => 3 triangles)
    else
        by center of edges (1 => 4 triangles)
    Handles normal, texCoord buffers
    color buffer handles incorrectly
]]      
function subdivide(m, method)
    local s_array_center = function(array)
        if #array % 3 ~= 0 then error("subdivide: length of array is not divisible of 3") end
        local t = {}
        local buff = 0
        for i = 0, #array/3-1 do
            buff = (array[i*3+1] + array[i*3+2] + array[i*3+3]) / 3
            ivert(t, array[i*3+1], buff, array[i*3+3],  array[i*3+1], array[i*3+2], buff,  buff, array[i*3+2], array[i*3+3])
        end
        return t
    end
    local s_array_edges = function (array)
        if #array % 3 ~= 0 then error("subdivide: length of array is not divisible of 3") end
        local t = {}
        local a,b,c = 0,0,0
        for i = 0, #array/3-1 do
            a = (array[i*3+1] + array[i*3+2])/2
            b = (array[i*3+2] + array[i*3+3])/2
            c = (array[i*3+1] + array[i*3+3])/2
            ivert(t, array[i*3+1],a,c, a,array[i*3+2],b,  c,a,b, c,b,array[i*3+3])
        end
        return t
    end
    local buff = 0
    local t = m:buffer("position"):get()
    if method then
        m.vertices = s_array_center(t)
    else
        m.vertices = s_array_edges(t)
    end
    buff = m:buffer("normal")
    if buff then
        t = buff:get()
        if method then
            m.normals = s_array_center(t)
        else
            m.normals = s_array_edges(t)
        end
    end
    buff = m:buffer("texCoord")
    if buff then
        t = buff:get()
        if method then
            m.texCoord = s_array_center(t)
        else
            m.texCoord = s_array_edges(t)
        end
    end
    buff = m:buffer("color")
    if buff then
        t = buff:get()
        if method then
            m.colors = s_array_center(t)
        else
            m.colors = s_array_edges(t)
        end
    end
end

--[[
    Calculate normals for mesh based on triangle as surface method
    Algorithm description: https://www.khronos.org/opengl/wiki/Calculating_a_Surface_Normal
]]
function calculateNormals(array, normals_in)
    local n,u,v = 0,0,0
    local norm = {}
    for i = 0, #array/3-1 do
        u = array[i*3+2] - array[i*3+1]
        v = array[i*3+3] - array[i*3+1]
        if normals_in then
            u = -u
            v = -v
        end
        n = vec3(u.y*v.z - u.z*v.y, u.z*v.x - u.x*v.z, u.x*v.y - u.y*v.x)
        ivert(norm, n, n, n)
    end
    return norm
end

--[[
    Allign mesh vertices or sphere with 
    radius = rad
    centred in model (0,0,0)
    Saves direction of vertices
]]
function tosphere(m, rad)
    local rad = rad or 1
    local buff = m:buffer("position")
    local t = buff:get()
    for i,v in ipairs(t) do
        t[i] = rad*v:normalize()
    end
    buff:set(t)
end