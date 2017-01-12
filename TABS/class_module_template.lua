--[[
    TEMP:
        _name
        _Name
        _NAME
]]
--[[
    DESCRIPTION: 
        Module contains implementation of _name class
    AUTHOR:
        Mikhail Demchenko
        dev.echo.mike@gmail.com
        https://github.com/echo-Mike
    v_0.0.1: 
        CREATED:
            Error facility:
                void C__NAME.error(const float error_type, ...)
            _name class definition:
                _name init(table t)
                
            Other local functions:
                
]]
--[[
    NAMESPACE:
        GLOBAL:
            variable C__NAME
            class _name
                _name init(table t)
                
        LOCAL:
            variable errors
            
]]
--[[
    TODOLIST:
        1: 
]]
--[[
    BUGLIST:
        NON
]]
--[[
    DEPENDENCIES: 
        NON
]]

--Module and module internal functions declaration
if C__NAME then
    error("c__Name: C__NAME variable is already occupied as: "..tostring(C__NAME))
end

C__NAME = {
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

--Error facility declaration
function C__NAME.error(error_type, ...)
    local t, s = {...}, "c__Name:"
    if error_type == errors. then
        s = s..""
    elseif error_type == errors. then
        s = s..""
    else
        s = s.."Unknown error type"
	end
    if C__NAME.no_errors == 1 then
        print(s)
    elseif C__NAME.no_errors == 2 then 
        io.stderr:write(s)
    else
        error(s)
    end
end

--Dependencies check

--No dependencies to check

--Local functions

--No local functions

--_name class definition

_name = class()

--This class uses underscores names notation

function _name:init(t)
    
end
