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
        bf_type = string.char(buff[1],buff[2]),
        bf_size = uint.from_bytes(buff[3],buff[4],buff[5],buff[6]),
        bf_reserved = string.char(109, 108, 105, 98),
        bf_off_bits = uint.from_bytes(buff[11],buff[12],buff[13],buff[14])
    }
    buff = handle:read(4)
    if uint.from_string(buff) ~= 124 then
        error("c_BMP: Only bmp files with BITMAPV5HEADER can be readed")
    end
    buff = handle:read(120)
    self.data.BITMAPV5HEADER = {
        bi_size = 124,
        bi_width = readDWORD(buff),
        bi_height = readDWORD(buff,1),
        bi_planes = readWORD(buff,0,8),
        bi_bit_count = readWORD(buff,1,8),
        bi_compression = readDWORD(buff,0,12),
        bi_size_image = readDWORD(buff, 1,12),
        bi_x_pixels_per_meter = readDWORD(buff, 2,12),
        bi_y_pixels_per_meter = readDWORD(buff, 3,12),
        bi_clr_used = readDWORD(buff, 4,12),
        bi_clr_important = readDWORD(buff, 5,12),
        bv4_red_mask = readDWORD(buff, 6,12),
        bv4_green_mask = readDWORD(buff, 7,12),
        bv4_blue_mask = readDWORD(buff, 8,12),
        bv4_alpha_mask = readDWORD(buff, 9,12),
        bv4_cs_type = readDWORD(buff, 10,12),
        bv4_end_points = {
            readDWORD(buff, 11,12),
            readDWORD(buff, 12,12),
            readDWORD(buff, 13,12),
            readDWORD(buff, 14,12),
            readDWORD(buff, 15,12),
            readDWORD(buff, 16,12),
            readDWORD(buff, 17,12),
            readDWORD(buff, 18,12),
            readDWORD(buff, 19,12)
        },
        bv4_gamma_red = readDWORD(buff, 20,12),
        bv4_gamma_green = readDWORD(buff, 21,12),
        bv4_gamma_blue = readDWORD(buff, 22,12),
        bv5_intent = readDWORD(buff, 23,12),
        bv5_profile_data = readDWORD(buff, 24,12),
        bv5_profile_size = readDWORD(buff, 25,12),
        bv5_reserved = readDWORD(buff, 26,12)
    }
end

function BMP:write(path)

end


--[[
    All data must be presented as strings
]]
local function readBYTE(data,offset)
    if position+offset > data:len() or position+offset < 0 then 
        error("c_BMP: Invalid position to read BYTE")
    end
    
    
end

local function readWORD(data,offset,position)
    local pos = position or 0
    local off = offset or 0   
    if (off+1)*2+pos > data:len() then 
        error("c_BMP: Invalid position to read WORD: "..tostring(off*2+pos+1))
    end
    return word.from_string(data,off*2+pos+1,off*2+pos+4)
end

local function readDWORD(data,offset,position)
    local pos = position or 0
    local off = offset or 0
    if (off+1)*4+pos > data:len() then 
        error("c_BMP: Invalid position to read DWORD: "..tostring(off*4+pos+1))
    end
    return uint.from_string(data,off*4+pos+1,off*4+pos+4)
end

local function writeBYTE(data,position,offset)

end

local function writeWORD(data,position,offset)

end

local function writeDWORD(data,position,offset)

end



