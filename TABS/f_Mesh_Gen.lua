--DESCRIPTION: Module contains functions that generate 3D primitives: UV-sphere; Cubic-sphere; Cylinder; Surface; Cube.
--DEPENDENCIES(STRONG): F_Utils:ivert(t, ...)
if F_MESH_GEN then
    print("f_Mesh_Gen: C_MESH_GEN variable is already occupied as: ", F_MESH_GEN)
else
    if not F_UTILS then
        print("f_Mesh_Gen: Module f_Utils needed")
    end
    F_MESH_GEN = true
end

--creates UV-sphere 
function makesphere(rad, Lsteps, Asteps, normals_in)
    local dl, da = math.pi*2/Lsteps, math.pi/Asteps
    if normals_in then
        dl = -dl
    end
    local hpi = math.pi/2
    local c = {vec3(0,-rad, 0), vec3(0, rad, 0)}
    for i = 1, Asteps-2 do
        for j = 1, Lsteps do
            table.insert(c, vec3(rad*math.cos(j*dl)*math.cos((i+1)*da-hpi), rad*math.sin((i+1)*da-hpi), rad*math.sin(j*dl)*math.cos((i+1)*da-hpi)))
        end
    end
    local vert = {}
    for j = 1, Lsteps do
        if j == Lsteps then
            ivert(vert, c[1], c[j+2], c[3])
        else
            ivert(vert, c[1], c[j+2], c[j+3]) --bottom
        end
    end
    for i= 1,Asteps-3 do
        for j = 1, Lsteps do
            if j == Lsteps then
                ivert(vert, c[Lsteps*(i-1)+j+2], c[Lsteps*i+j+2], c[Lsteps*(i-1)+3]) --face left
                ivert(vert, c[Lsteps*(i-1)+3], c[Lsteps*i+j+2], c[Lsteps*i+3]) --face right
            else
                ivert(vert, c[Lsteps*(i-1)+j+2], c[Lsteps*i+j+2], c[Lsteps*(i-1)+j+3]) --face left
                ivert(vert, c[Lsteps*(i-1)+j+3], c[Lsteps*i+j+2], c[Lsteps*i+j+3]) --face right
            end
        end
    end
    for j = 1, Lsteps do
        if j == Lsteps then
            ivert(vert, c[j+Lsteps*(Asteps-3)+2], c[2], c[Lsteps*(Asteps-3)+3])
        else
            ivert(vert, c[j+Lsteps*(Asteps-3)+2], c[2], c[j+Lsteps*(Asteps-3)+3]) --top 
        end
    end
    local m = mesh()
    m.vertices = vert
    return m
end

--creates sphere from cube
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
            --[[
            --OLD CODE:hard to change normal direction
            ivert(vert.f, pf[a], p.f[c], p.f[b], p.f[b], p.f[c], p.f[d])
            ivert(vert.l, p.l[a], p.l[c], p.l[b], p.l[b], p.l[c], p.l[d])
            ivert(vert.b, pb[a], p.b[c], p.b[b], p.b[b], p.b[c], p.b[d])
            ivert(vert.r, p.r[a], p.r[c], p.r[b], p.r[b], p.r[c], p.r[d])
            ivert(vert.d, pd[a], p.d[c], p.d[b], p.d[b], p.d[c], p.d[d])
            ivert(vert.t, p.t[a], p.t[c], p.t[b], p.t[b], p.t[c], p.t[d])
              ]]
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

--creates cylinder
function makecylinder(rad, heigh, steps)
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

--creates surface with length and width 100 in point center, normal have same direction as y axis
function makesurface(center)
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

--creates cube
function makecube(s)
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
