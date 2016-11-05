--Module dependencies: F_Utils:check(value, valuetype, errortext, errvalue)
if not C_CAMERA3D then
    if not F_UTILS then
        print("c_Camera3D: Module f_Utils needed")
    end
    C_CAMERA3D = true
end

camera3d = class()

function camera3d:init(camX,camY,camZ,lookX,lookY,lookZ,normX,normY,normZ)
    local cx,cy,cz = 0,0,0
    local lx,ly,lz = -1000,0,0
    local nx,ny,nz = 0,1,0
    if camX then cx = check(camX, "number", "camX is not number: ",cx) end
    if camY then cy = check(camY, "number", "camY is not number: ",cy) end
    if camZ then cz = check(camZ, "number", "camZ is not number: ",cz) end
    if normX then nx = check(normX, "number", "normX is not number: ",nx) end
    if normY then ny = check(normY, "number", "normY is not number: ",ny) end
    if normZ then nz = check(normZ, "number", "normZ is not number: ",nz) end
    if lookX then lx = check(lookX, "number", "lookX is not number: ",lx) end
    if lookY then ly = check(lookY, "number", "lookY is not number: ",ly) end
    if lookZ then lz = check(lookZ, "number", "lookZ is not number: ",lz) end
    self.pos  = vec3(cx,cy,cz)
    self.norm = vec3(nx,ny,nz)
    self.look = vec3(lx,ly,lz)
    self.ang  = {long = 0, alt = 0}
    local view_v = self.look - self.pos
    self.pos = v3to4(self.pos)
    local vvxz = vec2(view_v.x, view_v.z)
    self.ang.long = vvxz:angleBetween(vec2(1,0))
    self.ang.alt  = math.atan(view_v.y/vvxz:len())
    self.revers = vec2(1.0, 1.0)
    self.camera_transform_matrix = matrix()
end

function camera3d:control_view(deltaL, deltaA)
    if self.norm.y > 0 then
        self.ang.long = self.ang.long + self.revers.x*deltaL*math.pi
    else
        self.ang.long = self.ang.long - self.revers.x*deltaL*math.pi
    end
    self.ang.alt  = self.ang.alt  + self.revers.y*deltaA*math.pi
    if self.ang.long > math.pi*2 then self.ang.long = self.ang.long - 2*math.pi end
    if self.ang.alt  > math.pi*2 then self.ang.alt  = self.ang.alt  - 2*math.pi end
    self.lookx = 1000*math.cos(self.ang.long)*math.cos(self.ang.alt) + self.pos.x
    self.look.z = 1000*math.sin(self.ang.long)*math.cos(self.ang.alt) + self.pos.z
    self.look.y = 1000*math.sin(self.ang.alt) + self.pos.y
    self.norm.x = math.cos(self.ang.long)*math.cos(math.pi/2+self.ang.alt)
    self.norm.z = math.sin(self.ang.long)*math.cos(math.pi/2+self.ang.alt)
    self.norm.y = math.sin(math.pi/2+self.ang.alt)
end

--camera mowvement
function camera3d:moveto(X,Y,Z)
    self.camera_transform_matrix[13]=0
    self.camera_transform_matrix[14]=0
    self.camera_transform_matrix[15]=0
    self:translate(X,Y,Z)
end

function camera3d:vmoveto(v)
    self:move_to(v.x,v.y,v.z)
end

function camera3d:translate(dx,dy,dz)
    self.camera_transform_matrix = self.camera_transform_matrix:translate(dx,dy,dz)
end

function camera3d:vtranslate(dv)
    self:translate(dv.x,dv.y,dv.z)
end

function camera3d:clear_transform_matrix()
    self.camera_transform_matrix = matrix()
end

--3D camera setup
function camera3d:camera()
    camera(self.pos.x,self.pos.y,self.pos.z, selflook.x,self.look.y,self.look.z, self.norm.x,self.norm.y,self.norm.z)
end

--GUI camera setup
function camera3d:gui()
    camera(0,0,0, 0,0,-10, 0,1,0)
end
