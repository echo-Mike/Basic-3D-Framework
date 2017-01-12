--[[
    DESCRIPTION: 
        Module contains implementation of camera3d class
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.3:
        NEW:
            New description of vec2, vec3 variables types as Codea:Type in DESCRIPTION and NAMESPACE sections
            Local functions place in file (after dependencies check)
        CREATED:
            Codea classes dependencies check
            An error to handle Codea classes missing: 
                NAME: errors.NO_CODEA = 2
                ERROR_STRING: "Runing without Codea classes"
            c_Viewport dependencies check
            An error to handle c_Viewport missing:
                NAME: errors.NO_C_VIEWPORT = 3
                ERROR_STRING: "Module c_Viewport needed"
            BUGLIST section
            camera3d class definition:
                boolean[,string] orientationChanged(const float ori)
        UPDATED:
            camera3d class definition:
                boolean[,string] camera(void)
                boolean[,string] gui(void)
                boolean[,string] draw(void)
                    Nested events of self.viewport now correctly handled
    v_0.0.2:
        CREATED:
            NAMESPACE section
        BUGSCLOSED:
            Mikhali instead of Mikhail in AUTHOR section
            C_SCENE in C_CAMERA3D.error function
    v_0.0.1: 
        CREATED: 
            Error facility:
                void C_CAMERA3D.error(const float error_type, ...)
            camera3d class definition:
                boolean[,string] draw(void)
                boolean validate(void)
                void sync_look_at(void)
                void sync_fps(void)
            Other local functions:
                void v_camera(Codea:vec3 pos, Codea:vec3 look, Codea:vec3 norm)
        RECREATED:
            camera3d class definition:
                camera3d init(table t)
                boolean[,string] camera(void)
                boolean[,string] gui(void)
                void control_view(float deltaL, float deltaA)
        DELETED:
            camera3d class definition:
                void moveto(float X, float Y, float Z)
                void vmoveto(Codea:vec3 v)
                void translate(float dx, float dy, float dz)
                void vtranslate(Codea:vec3 dv)
                void clear_transform_matrix()
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable C_CAMERA3D
            class camera3d
                camera3d init(table t)
                void sync_look_at(void)
                void sync_fps(void)
                boolean[,string] camera(void)
                boolean[,string] gui(void)
                boolean[,string] draw(void)
                void control_view(float deltaL, float deltaA)
                boolean[,string] orientationChanged(const float ori)
                boolean validate(void)
        LOCAL:
            variable errors
            void v_camera(Codea:vec3 pos, Codea:vec3 look, Codea:vec3 norm)
]]
--[[
    TODOLIST:
        1: добавить интерфейс управления viewport
        2: создать интерфейс управления движением и направлением камеры
        3: сделать проще внутренние имена внешних переменных
        4: 
]]
--[[
    BUGLIST:
        D756D3B7: Open
        A78A3B3D: Open
]]
--[[
    DEPENDENCIES(STRONG): 
        c_Viewport:viewport
        Codea:camera()
        Codea:vec2()
        Codea:vec3()
]]

--Module and module internal functions declaration
if C_CAMERA3D then
    error("c_Camera3D: C_CAMERA3D variable is already occupied as: "..tostring(C_CAMERA3D))
end

C_CAMERA3D = {
    loaded = true,
    c_viewport_loaded = true,
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
errors.VALID_VIEWPORT = 0
errors.VALID_VIEWPORT_CONTENT = 1
errors.NO_CODEA = 2
errors.NO_C_VIEWPORT = 3

--Error facility declaration
function C_CAMERA3D.error(error_type, ...)
    local t, s = {...}, "c_Camera3D:"
    if error_type == errors.VALID_VIEWPORT then
        s = s.."Viewport must be a \"viewport\" class member but it have type: "..type(t[1]).." and value: "..tostring(t[1])
    elseif error_type == errors.VALID_VIEWPORT_CONTENT then
        s = s.."Viewport is not valid"
    elseif error_type == errors.NO_CODEA then
        s = s.."Runing without Codea classes"
    elseif error_type == errors.NO_C_VIEWPORT then
        s = s.."Module c_Viewport needed"
    else
        s = s.."Unknown error type"
	end
    if C_CAMERA3D.no_errors == 1 then
        print(s)
    elseif C_CAMERA3D.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--STRONG:
--Check Codea classes, functions loaded
if (not camera) or (not vec2) or (not vec3) then
    C_CAMERA3D.loaded = false
    C_CAMERA3D.error(errors.NO_CODEA)
end

require("c_Viewport")
--Check c_Viewport module loaded
if (not C_VIEWPORT) or (not C_VIEWPORT.loaded) then
    C_CAMERA3D.loaded = false
    C_CAMERA3D.c_viewport_loaded = false
    C_CAMERA3D.error(errors.NO_C_VIEWPORT)
end

--Local functions

--Call std Codea function "camera()" with vector(vec3) parameters 
local function v_camera(pos,look,norm)
    camera(pos.x,pos.y,pos.z, look.x,look.y,look.z, norm.x,norm.y,norm.z)
end

--camera3d class definition

camera3d = class()

--This class uses underscores names notation

function camera3d:init(t)
    --Read camera position, every type need one
    self.position = t.cam or vec3(0)
    --Read std Codea camera parameters
    self.look_at = {} 
    self.look_at.look = t.look or vec3(-1,0,0)
    self.look_at.norm = t.norm or vec3(0,1,0)
    --[[
        Convert Codea camera to camera defined 
        by position, altitude angle and longitude angle
        (typically called FPS camera)
    ]]
    self.fps = {
        long = 0,
        alt = 0
    }
    self:sync_fps()
    self.viewport = t.viewport or viewport()
    self.valid = self:validate()
end

--Setup "Look At" camera data with current "FPS" camera data
function camera3d:sync_look_at()
    self.look_at.look.x = math.cos(self.fps.long)*math.cos(self.fps.alt)
    self.look_at.look.z = math.sin(self.fps.long)*math.cos(self.fps.alt)
    self.look_at.look.y = math.sin(self.fps.alt)
    self.look_at.look = self.look_at.look + self.position
    self.look_at.norm.x = -math.cos(self.fps.long)*math.sin(self.fps.alt)
    self.look_at.norm.z = -math.sin(self.fps.long)*math.sin(self.fps.alt)
    self.look_at.norm.y = math.cos(self.fps.alt)
end

--Setup "FPS" camera data with current "Look At" camera data
function camera3d:sync_fps()
    local view_v = self.look_at.look - self.position
    local vvxz = vec2(view_v.x, view_v.z)
    self.fps.long = vvxz:angleBetween(vec2(1,0))
    self.fps.alt  = math.atan(view_v.y/vvxz:len())
end

--Setup camera and viewport parameters for 3D drawing
function camera3d:camera()
    if not self.valid then 
        return nil, "c_Camera3D.camera:Camera is not valid"
    end
    self:sync_look_at()
    v_camera(self.position, self.look_at.look, self.look_at.norm)
    return self.viewport:setup_3d()
end

--Setup camera and viewport parameters for 2D drawing
function camera3d:gui()
    if not self.valid then 
        return nil, "c_Camera3D.gui:Camera is not valid"
    end
    camera(0,0,0, 0,0,-10, 0,1,0)
    return self.viewport:setup_2d()
end

--Draw saved canvases on screen
function camera3d:draw()
    if not self.valid then 
        return nil, "c_Camera3D.draw:Camera is not valid"
    end
    camera(0,0,0, 0,0,-10, 0,1,0)
    return self.viewport:draw()
end

--Control camera(fps) look direction 
function camera3d:control_view(deltaL, deltaA)
    if self.norm.y > 0 then
        self.ang.long = self.ang.long + self.revers.x*deltaL*math.pi
    else
        self.ang.long = self.ang.long - self.revers.x*deltaL*math.pi
    end
    self.ang.alt  = self.ang.alt  + self.revers.y*deltaA*math.pi
    if self.ang.long > math.pi*2 then self.ang.long = self.ang.long - 2*math.pi end
    if self.ang.alt  > math.pi*2 then self.ang.alt  = self.ang.alt  - 2*math.pi end
    self:sync_look_at()
end

--Handler of "orientation changed" event
function camera3d:orientationChanged(ori)
    if not self.valid then 
        return nil, "c_Camera3D.orientationChanged:Camera is not valid"
    end
    if self.viewport then
        return self.viewport:orientationChanged(ori)
    end
    return nil, "c_Camera3D.orientationChanged:Event wasn't handeled by internal viewport"
end

--[[
    Start validation of all internal and external data in current object. 
    Return true if data is valid and false if it is not
]]
function camera3d:validate()
    if camera3d.is_a(self.viewport, viewport) then
        if not self.viewport.valid then
            C_CAMERA3D.error(errors.VALID_VIEWPORT_CONTENT,self.viewport)
        end
    else
        C_CAMERA3D.error(errors.VALID_VIEWPORT,self.viewport)
        return false
    end
    return true
end