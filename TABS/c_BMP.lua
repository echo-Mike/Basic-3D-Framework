require('Codea_classes.Class')
require('c_UInt')

image = class()

function image:init(width, height)
    
end

function image:get(x,y)
    
end

function image:set(x,y,color)

end

function image:copy(x,y,w,h)

end

BMP = class()

function BMP:init(source) 
    if type(source) ~= "string" then error("c_BMP: Only strings allowed as source") end
    self.source = source
    self.data = {
        BITMAPFILEHEADER = {},
        BITMAPV5HEADER = {},
        COLORTABLE = {},
        PIXELARRAY = {},
        ICCCOLORPROFILE = {}
    }
end

function BMP:read()
    local handle, err = io.open(slef.source,"rb")
    if not handle then error(err) end
    local buff = 0
    buff = handle:read(14)
    if not buff then 
        error("c_BMP: Can't read BITMAPFILEHEADER")
    end
    buff = {buff:byte(1,14)}
    if buff[1] ~= 66 and buff[2] ~= 77 then
        error("c_BMP: Invalid file signature")
    end
    self.data.BITMAPFILEHEADER = {
        signature = string.char(buff[1],buff[2]),
        file_size = uint.from_bytes(buff[3],buff[4],buff[5],buff[6]),
        reserved = string.char(109, 108, 105, 98),
        pixel_array_offset = uint.from_bytes(buff[11],buff[12],buff[13],buff[14])
    }
    buff = handle:read(4)
    if uint.from_string(buff) ~= 124 then
        error("c_BMP: Only bmp files with BITMAPV5HEADER can be readed")
    end
    buff = handle:read(120)
    
    self.data.BITMAPV5HEADER = {
        bi_size = 124,
        bi_width = 
    }
end

function BMP:write(path)

end


--[[
    All data must be presented as strings
]]
local function readBYTE(data,position,offset)
    if position+offset > data:len() or position+offset < 0 then 
        error("c_BMP: Invalid position to read BYTE")
    end
    
    
end

local function readWORD(data,position,offset)
    if position+offset > data:len() or position+offset < 0 then 
        error("c_BMP: Invalid position to read WORD")
    end
    
end

local function readDWORD(data,position,offset)
    if position+offset > data:len() or position+offset < 0 then 
        error("c_BMP: Invalid position to read DWORD")
    end
    
end

local function writeBYTE(data,position,offset)

end

local function writeWORD(data,position,offset)

end

local function writeDWORD(data,position,offset)

end



