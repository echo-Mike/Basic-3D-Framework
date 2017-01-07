function set_box_texture(mes, tex)
    local t = { vec2(0,0),vec2(1,0),vec2(0,1),vec2(1,1) }
    local texC = {
        t[1], t[2], t[4], t[1], t[4], t[3], --Front 
        t[1], t[2], t[4], t[1], t[4], t[3], --Right 
        t[1], t[2], t[4], t[1], t[4], t[3], --Back 
        t[1], t[2], t[4], t[1], t[4], t[3], --Left 
        t[1], t[2], t[4], t[1], t[4], t[3], --Top 
        t[1], t[2], t[4], t[1], t[4], t[3]  --Bottom
    }
    mes.texture = tex
    mes.texCoords = texC
end

function set_surface_texture(mes, tex)
    local texC = {
        vec2(0,0), vec2(1,0), vec2(0,1),
        vec2(0,1), vec2(1,0), vec2(1,1)
    }
    mes.texture = tex
    mes.texCoords = texC
end

function set_sphere_texture(mes, tex, Lsteps, Asteps)
    local dl, da = 1.0/Lsteps, 1.0/(Asteps-1)
    local texC = {}
    for j = 1, Lsteps do
        ivert(texC, vec2((j-1)*dl, 0.0), vec2((j-1)*dl, da), vec2(j*dl,da)) --bottom
    end
    for i = 1, Asteps-3 do
        for j = 1, Lsteps do
            ivert(texC, vec2((j-1)*dl, i*da), vec2((j-1)*dl, (i+1)*da), vec2(j*dl, i*da)) -- face left
            ivert(texC, vec2(j*dl, i*da), vec2((j-1)*dl, (i+1)*da), vec2(j*dl, (i+1)*da)) -- face right
        end
    end
    for j = 1, Lsteps do
        ivert(texC, vec2((j-1)*dl, 1.0-da), vec2((j-1)*dl,1.0), vec2(j*dl, 1.0-da)) -- top
    end
    mes.texture = tex
    mes.texCoords = texC
end
