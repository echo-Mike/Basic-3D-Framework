--[[
    DESCRIPTION: 
        Module contains implementation of viewport class
    AUTHOR:
        Mikhali Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.1: 
        CREATED: 
            Error facility:
                void C_VIEWPORT.error(const float error_type, ...)
            viewport class definition:
                viewport init(table t)
                boolean[,string] setup_3d()
                boolean[,string] setup_2d()
                boolean[,string] draw()
                boolean validate()
]]                
--[[
    TODOLIST:
        1: создать интерфейс управления параметрами
]]
--[[
    DEPENDENCIES: 
        NON
]]

--Module and module internal functions declaration
if C_VIEWPORT then
    error("c_Viewport: C_VIEWPORT variable is already occupied as: "..tostring(C_VIEWPORT))
end

C_VIEWPORT = {
    loaded = true,
    --[[
        Error facility behavior qualifier: 
        0:raise lua error
        1:print error messege to stdout
        2:print error messege to stderr
    ]]
    no_errors = 0,
    version = "0.0.1"
}

--Error declaration based on Codea autofill specifics
local errors = {}
errors.VALID_WRONG_TYPE = 0
errors.VALID_NO_KEY = 1

--Error facility declaration
function C_VIEWPORT.error(error_type, ...)
    local t, s = {...}, "c_Viewport:"
    if error_type == errors.VALID_WRONG_TYPE then
        s = s..tostring(t[1]).." must be \""..t[2].."\" but have type: "..type(t[3])
    elseif error_type == errors.VALID_NO_KEY then
        s = s.."Key: "..tostring(t[1]).." is missing in table: "..t[2]
    else
        s = s.."Unknown error type"
	end
    if C_SCENE.no_errors == 1 then
        print(s)
    elseif C_SCENE.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--No dependencies to check

--viewport class definition
viewport = class()

--This class uses underscores names notation

function viewport:init(t)
    self.world_canvas = t.world_canvas or image(WIDTH, HEIGHT)
    self.interface_canvas = t.interface_canvas or image(WIDTH, HEIGHT)
    --self.world_canvas.premultiplied = true
    --self.interface_canvas.premultiplied = true
    self.perspective = t.perspective or {fov = 100, aspect = WIDTH/HEIGHT, near = 0.1, far = 10000}
    self.ortho = t.ortho or {left = 0, right = WIDTH, bottom = 0, top = HEIGHT, near = -10, far = 10}
    self.world_color = t.world_color or color(0)
    self.scene_color = t.scene_color or color(45)
    self.valid = self:validate()
end

--Setup camera and viewport parameters for 3D drawing
function viewport:setup_3d()
    if not self.valid then 
        return nil, "c_Viewport.setup_3d:Viewport is not valid"
    end
    background(self.world_color)
    setContext(self.world_canvas, true)
    background(self.scene_color)
    perspective(self.perspective.fov, self.perspective.aspect, self.perspective.near, self.perspective.far)
    return true
end

--Setup camera and viewport parameters for 2D drawing
function viewport:setup_2d()
    if not self.valid then 
        return nil, "c_Viewport.setup_2d:Viewport is not valid"
    end
    setContext(self.interface_canvas, true)
    ortho(self.ortho.left, self.ortho.right, self.ortho.bottom, self.ortho.top, self.ortho.near, self.ortho.far)
    return true
end

--Draw prepared canvases on screen
function viewport:draw()
    if not self.valid then 
        return nil, "c_Viewport.draw:Viewport is not valid"
    end
    setContext()
    ortho(self.ortho.left, self.ortho.right, self.ortho.bottom, self.ortho.top, self.ortho.near, self.ortho.far)
    sprite(self.world_canvas, WIDTH/2, HEIGHT/2)
    sprite(self.interface_canvas)
    return true
end

--[[
    Start validation of all internal and external data in current object. 
    Return true if data is valid and false if it is not
]]
function viewport:validate()
    local pers = {fov=0, aspect=0, near=0, far=0}
    local orth = {left=0, right=0, bottom=0, top=0, near=0, far=0}
    local buff
    if type(self.world_canvas) ~= "usedata" then
         C_VIEWPORT.error(errors.VALID_WRONG_TYPE, "world_canvas", "usedata", self.world_canvas)
        return false
    end
    if type(self.interface_canvas) ~= "usedata" then
         C_VIEWPORT.error(errors.VALID_WRONG_TYPE, "interface_canvas", "usedata", self.interface_canvas)
        return false
    end
    if type(self.perspective) ~= "table" then
         C_VIEWPORT.error(errors.VALID_WRONG_TYPE, "perspective", "table", self.perspective)
        return false
    end
    if type(self.ortho) ~= "table" then
         C_VIEWPORT.error(errors.VALID_WRONG_TYPE, "ortho", "table", self.ortho)
        return false
    end
    for k,_ in pairs(pers) do
        if self.perspective[k] then
            if type(self.perspective[k]) ~= "number" then
                C_VIEWPORT.error(errors.VALID_WRONG_TYPE, k, "number", self.perspective[k])
                return false
            end
        else
            C_VIEWPORT.error(errors.VALID_NO_KEY, k, "self.perspective")
            return false
        end
    end
    for k,_ in pairs(orth) do
        if self.ortho[k] then
            if type(self.ortho[k]) ~= "number" then
                 C_VIEWPORT.error(errors.VALID_WRONG_TYPE, k, "number", self.perspective[k])
                return false
            end
        else
            C_VIEWPORT.error(errors.VALID_NO_KEY, k, "self.ortho")
            return false
        end
    end
    return true
end