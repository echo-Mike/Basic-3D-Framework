--[[
    DESCRIPTION: 
        Module contains implementation of scene class
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.4:
        NEW:
            Local functions place in file (after dependencies check)
        CREATED:
            c_Interface dependencies check
            An error to handle c_Interface missing:
                NAME: errors.NO_C_INTERFACE = 6
                ERROR_STRING: "Module c_Interface needed"
            c_Camera3D dependencies check
            An error to handle c_Camera3D missing:
                NAME: errors.NO_C_CAMERA3D = 7
                ERROR_STRING: "Module c_Camera3D needed"
            c_Model dependencies check
            An error to handle c_Model missing:
                NAME: errors.NO_C_MODEL = 8
                ERROR_STRING: "Module c_Model needed"
            c_Light dependencies check
            An error to handle c_Light missing:
                NAME: errors.NO_C_LIGHT = 9
                ERROR_STRING: "Module c_Light needed"
            BUGLIST section
        UPDATED:
            Function boolean[,string] scene:orientationChanged(const float ori)
                camera object(viewport) call on "orientation changed" event added
    v_0.0.3:
        CREATED:
            NAMESPACE section
        BUGSCLOSED:
            Mikhali instead of Mikhail in AUTHOR section
    v_0.0.2:
        UPDATED:
            NULL() --Function place in file
            check_table_content_class() --Function place in file
            sceen.draw() --Current camera "draw" call added
        CREATED:
            TODOLIST section
    v_0.0.1: 
        CREATED: 
            Error facility:
                void C_SCENE.error(const float error_type, ...)
            scene class definition:
                scene init(table t)
                boolean[,string] draw(void)
                boolean[,string] touched(touch touch)
                boolean[,string] keyboard(char key)
                boolean[,string] orientationChanged(const float ori)
                boolean validate(void)
            Other local functions:
                void NULL()
                boolean[,float][,string] check_table_content_class(table t, class_table klass)
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable C_SCENE
            class scene
                scene init(table t)
                boolean[,string] draw(void)
                boolean[,string] touched(touch touch)
                boolean[,string] keyboard(char key)
                boolean[,string] orientationChanged(const float ori)
                boolean validate(void)
        LOCAL:
            variable errors
            void NULL(void)
            boolean[,float][,string] check_table_content_class(table t, class_table klass)
]]
--[[
    TODOLIST:
        1: сделать возврат от V_PHYSICS.setup указатель на функцию обновления
        2: сделать возврат от V_ANIMATION.setup указатель на функцию обновления
]]
--[[
    BUGLIST:
        D756D3B7: Open
]]
--[[
    DEPENDENCIES: 
        c_Camera3D:camera3d
        c_Interface:interface
        c_Model:model
        c_Light:light
]]

--Module and module internal functions declaration
if C_SCENE then
    error("c_Scene: C_SCENE variable is already occupied as: "..tostring(C_SCENE))
end

C_SCENE = {
    loaded = true,
    c_interface_loaded = true,
    c_camera3d_loaded = true,
    c_model_loaded = true,
    c_light_loaded = true,
    --[[
        Error facility behavior qualifier: 
        0:raise lua error
        1:print error messege to stdout
        2:print error messege to stderr
    ]]
    no_errors = 0,
    version = "0.0.4"
}

--Error declaration based on Codea autofill specifics
local errors = {}
errors.VALID_INTERFACE = 0
errors.VALID_INTERFACE_ELECTOR = 1
errors.VALID_CAMERA = 2
errors.VALID_CAMERA_ELECTOR = 3
errors.VALID_MODEL = 4
errors.VALID_LIGHT_SOURCE = 5
errors.NO_C_INTERFACE = 6
errors.NO_C_CAMERA3D = 7
errors.NO_C_MODEL = 8
errors.NO_C_LIGHT = 9

--Error facility declaration
function C_SCENE.error(error_type, ...)
    local t, s = {...}, "c_Scene:"
    if error_type == errors.VALID_INTERFACE then
        s = s.."Can't validate all interface_storage elements, interrupt position: "..tostring(t[1])
    elseif error_type == errors.VALID_INTERFACE_ELECTOR then
        s = s.."interface_elector must be a \"number\" but it have type: "..type(t[1]).." and value: "..tostring(t[1])
    elseif error_type == errors.VALID_CAMERA then
        s = s.."Can't validate all camera_storage elements, interrupt position: "..tostring(t[1])
    elseif error_type == errors.VALID_CAMERA_ELECTOR then
        s = s.."camera_elector must be a \"number\" but it have type: "..type(t[1]).." and value: "..tostring(t[1])
    elseif error_type == errors.VALID_MODEL then
        s = s.."Can't validate all model_storage elements, interrupt position: "..tostring(t[1])
    elseif error_type == errors.VALID_LIGHT_SOURCE then
        s = s.."Can't validate all light_storage elements, interrupt position: "..tostring(t[1])
    elseif error_type == errors.NO_C_INTERFACE then
        s = s.."Module c_Interface needed"
    elseif error_type == errors.NO_C_CAMERA3D then
        s = s.."Module c_Camera3D needed"
    elseif error_type == errors.NO_C_MODEL then
        s = s.."Module c_Model needed"
    elseif error_type == errors.NO_C_LIGHT then
        s = s.."Module c_Light needed"
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

--STRONG:
require("c_Interface")
--Check c_Interface module loaded
if (not C_INTERFACE) or (not C_INTERFACE.loaded) then
    C_SCENE.loaded = false
    C_SCENE.c_interface_loaded = false
    C_SCENE.error(errors.NO_C_INTERFACE)
end

require("c_Camera3D")
--Check c_Camera3D module loaded
if (not C_CAMERA3D) or (not C_CAMERA3D.loaded) then
    C_SCENE.loaded = false
    C_SCENE.c_camera3d_loaded = false
    C_SCENE.error(errors.NO_C_CAMERA3D)
end

require("c_Model")
--Check c_Model module loaded
if (not C_MODEL) or (not C_MODEL.loaded) then
    C_SCENE.loaded = false
    C_SCENE.c_model_loaded = false
    C_SCENE.error(errors.NO_C_MODEL)
end

require("c_Light")
--Check c_Light module loaded
if (not C_LIGHT) or (not C_LIGHT.loaded) then
    C_SCENE.loaded = false
    C_SCENE.c_light_loaded = false
    C_SCENE.error(errors.NO_C_LIGHT)
end

--Local functions

--Function that do nothing except it can be called as NULL()
local function NULL() end

--[[
    Checks content of the table "t" to be a class members of class "klass"
    Return true if all content is a class members of "klass"
    Otherwise return false and key of object that is not in "klass" class
]]
local function check_table_content_class(t, klass)
    for k,v in pairs(t) do
        if not v:is_a(klass) then
            return false, k
        end
    end
    return true
end

--scene class definition

scene = class()

--This class uses underscores names notation

function scene:init(t)
    --Interface class object/s setup
    self.interface_storage = t.interface_storage or {interface()}
    self.interface_elector = t.interface_elector or 1
    --Camera class object/s setup
    slef.camera_storage = t.camera_storage or {camera3d()}
    self.camera_elector = t.camera_elector or 1
    --Model and Light_Source storage setups
    self.model_storage = t.model_storage or {}
    self.light_storage = t.light_storage or {}
    --Animation engine setup
    if t.animation then
        self.animation = V_ANIMATION.setup(self,t.animation)
        self.animation_callback = t.animation_callback or NULL
    end
    --Physics engine setup
    if t.physics then
        self.physics = V_PHYSICS.setup(self,t.physics)
        self.physics_callback = t.physics_callback or NULL
    end
    self.valid = self:validate()
end

--Draw event handler
function scene:draw()
    if not self.valid then 
        return nil, "c_Scene.draw:Sceen is not valid"
    end
    --Make step(call update function) in physics(first) and animation(second) engines
    if self.physics then self.physics_callback(self.physics()) end
    if self.animation then self.animation_callback(self.animation()) end
    --Setup camera and viewport parameters for 3D drawing
    self.camera_storage[self.camera_elector]:camera()
    --Draw all 3D objects
    for k,v in pairs(self.model_storage) do
        v:draw(k)
    end
    --Setup camera and viewport parameters for 2D drawing
    self.camera_storage[self.camera_elector]:gui()
    --Draw all gui objects
    self.interface_storage[self.interface_elector]:draw()
    --Draw saved canvases on screen
    self.camera_storage[self.camera_elector]:draw()
    return true
end

--Touch event handler
function scene:touched(touch)
    if not self.valid then 
        return nil, "c_Scene.touched:Sceen is not valid"
    end
    self.interface_storage[self.interface_elector]:touched(touch)
    return true
end

--Keyboard event handler
function scene:keyboard(key)
    if not self.valid then 
        return nil, "c_Scene.keyboard:Sceen is not valid"
    end
    self.interface_storage[self.interface_elector]:keyboard(key)
    return true
end

--Orientation Changed event handler
function scene:orientationChanged(ori)
    if not self.valid then 
        return nil, "c_Scene.orientationChanged:Sceen is not valid"
    end
    self.camera_storage[self.camera_elector]:orientationChanged(ori)
    self.interface_storage[self.interface_elector]:orientationChanged(ori)
    return true
end

--[[
    Start validation of all internal and external data in current object. 
    Return true if data is valid and false if it is not
]]
function scene:validate()
    local detector, buff = 0, 0
    --Validation of interface_storage content as elements of interface calss
    detector, buff = check_table_content_class(self.interface_storage,interface)
    if not detector then 
        C_SCENE.error(errors.VALID_INTERFACE, buf)  
        return false
    end
    --Validation of interface_elector as number
    if type(self.interface_elector) ~= "number" then 
        C_SCENE.error(errors.VALID_INTERFACE_ELECTOR,self.interface_elector)  
        return false
    end
    --Validation of camera_storage content as elements of camera3d calss
    detector, buff = check_table_content_class(self.camera_storage,camera3d)
    if not detector then 
        C_SCENE.error(errors.VALID_CAMERA, buf)
        return false
    end
    --Validation of camera_elector as number
    if type(self.camera_elector) ~= "number" then 
        C_SCENE.error(errors.VALID_CAMERA_ELECTOR,self.camera_elector)  
        return false
    end
    --Validation of model_storage content as elements of model calss
    if #self.model_storage ~= 0 then 
        detector, buff = check_table_content_class(self.model_storage,model) 
        if not detector then 
            C_SCENE.error(errors.VALID_MODEL, buf)  
            return false
        end
    end
    --Validation of light_storage content as elements of light calss
    if #self.light_storage ~= 0 then 
        detector, buff = check_table_content_class(self.light_storage,light) 
        if not detector then 
            C_SCENE.error(errors.VALID_LIGHT_SOURCE, buf)  
            return false
        end
    end
    --Start validation in physics and animation engines if it is presented
    buff = true
    if self.physics then 
        buff = V_PHYSICS.validate()
    end
    if self.animation then
        buff = buff and V_ANIMATION.validate()
    end
    return buff
end