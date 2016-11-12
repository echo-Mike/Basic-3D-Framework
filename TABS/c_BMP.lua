require('Codea_classes.Class')
require('c_UInt')
require('c_Word')
require('f_Utils')

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

local BMP_ERROR_HANDLER = {}

BMP_ERROR_HANDLER.err_types = {
    
}

function BMP_ERROR_HANDLER.error(err_type, ...)

end

local header_types = {
    BITMAPCOREHEADER = 0,
    BITMAPINFOHEADER = 1,
    BITMAPV4HEADER = 2,
    BITMAPV5HEADER = 3
}

function BMP:init(source) 
    if type(source) ~= "string" then error("c_BMP: Only strings allowed as source or path") end
    self.source = source
    self.data = {}
end

--Create BMP from self.source as data string
function BMP:read()
    self:load(true)
end

--Create BMP from self.source as path(std) or self.source as data string
function BMP:load(source)
    local buff = 0
    if source then
        handle = self.source
        buff = handle(1,14)
    else
        local handle, err = io.open(slef.source,"rb")
        if not handle then error(err) end
        buff = handle:read(14)
        if not buff then error("c_BMP: Can't read BITMAPFILEHEADER") end
    end
    self.data.BITMAPFILEHEADER = {
        bf_type = readWORD(buff),
        bf_size = readDWORD(buff,0,2),
        bf_reserved = uint(),
        bf_off_bits = readDWORD(buff,2,2)
    }
    if self.data.BITMAPFILEHEADER.bf_type:neq("BM") then
        error("c_BMP: Invalid file signature")
    end    
    if source then
        buff = handle(15,18)
    else
        buff = handle:read(4)
    end
    buff = uint.from_string(buff)
    if buff:eq(12) then
        readBITMAPCOREHEADER(handle, self)
    elseif buff:eq(40) then
        readBITMAPINFOHEADER(handle, self)
    elseif buff:eq(108) then
        readBITMAPV4HEADER(handle, self)
    elseif buff:eq(124) then
        readBITMAPV5HEADER(handle, self)
    else
        error("c_BMP: Invalid DIBHEADER size: "..tostring(buff))
    end
    if self.valid then
        readPIXELARRAY(handle, self, source)
    else
        io.stderr:write("c_BMP: Pixel array does not readed")
    end
    if source then handle:close() end
end

--Write BMP data to file defined as path
function BMP:write(path)

end

--Write BMP data to file defined as self.source
function BMP:save()
    return self:write(self.source)
end

--Read DIBHEADER version: CORE
local function readBITMAPCOREHEADER(handle, object)
    if type(handle) == "userdata" then
        local buff = handle:read(8)
    else
        local buff = handle(19,26)
    end
    local BITMAPCOREHEADER = {
        bi_size = uint(12),
        bi_width = readWORD(buff),
        bi_height = readWORD(buff,1),
        bi_planes = readWORD(buff,2),
        bi_bit_count = readWORD(buff,3),
    }
    if BITMAPCOREHEADER.bi_bit_count:neq(24) then
        object.valid = false
        error("c_BMP: Only 24 bits per pixel format is supported for BITMAPCOREHEADER")
    end
    object.data.DIBHEADER = BITMAPCOREHEADER
    object.data.DIBHEADERTYPE = header_types.BITMAPCOREHEADER
    object.valid = true
end

--Read DIBHEADER version: 3
local function readBITMAPINFOHEADER(handle, object)
    if type(handle) == "userdata" then
        local buff = handle:read(36)
    else
        local buff = handle(19,54)
    end
    local BITMAPINFOHEADER = {
        bi_size = uint(40),
        bi_width = readDWORD(buff),
        bi_height = readDWORD(buff,1),
        bi_planes = readWORD(buff,0,8),
        bi_bit_count = readWORD(buff,1,8),
        bi_compression = readDWORD(buff,0,12),
        bi_size_image = readDWORD(buff, 1,12),
        bi_x_pixels_per_meter = readDWORD(buff, 2,12),
        bi_y_pixels_per_meter = readDWORD(buff, 3,12),
        bi_clr_used = readDWORD(buff, 4,12),
        bi_clr_important = readDWORD(buff, 5,12)
    }
    if BITMAPINFOHEADER.bi_bit_count:neq(32) or BITMAPINFOHEADER.bi_bit_count:neq(24) then 
        object.valid = false
        error("c_BMP: Only 32 and 24 bits per pixel format is supported for BITMAPINFOHEADER")
    end
    if BITMAPINFOHEADER.bi_compression:neq(0) then
        object.valid = false
        error("c_BMP: Only non compressed pixel array are supported")
    end
    if BITMAPINFOHEADER.bi_clr_used:neq(0) then
        object.valid = false
        error("c_BMP: Only non color map bitmaps are supported")
    end
    object.data.DIBHEADER = BITMAPINFOHEADER
    object.data.DIBHEADERTYPE = header_types.BITMAPINFOHEADER
    object.valid = true
end

--Read DIBHEADER version: 4
local function readBITMAPV4HEADER(handle, object)
    if type(handle) == "userdata" then
        local buff = handle:read(104)
    else
        local buff = handle(19,122)
    end
    local BITMAPV4HEADER = {
        bi_size = uint(108),
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
        bv4_gamma_blue = readDWORD(buff, 22,12)
    }
    if BITMAPV4HEADER.bi_bit_count:neq(32) then 
        object.valid = false
        error("c_BMP: Only 32 and 24 bits per pixel format is supported for BITMAPV4HEADER")
    end
    if BITMAPV4HEADER.bi_compression:neq(0) then
        object.valid = false
        error("c_BMP: Only non compressed pixel array are supported")
    end
    if BITMAPV4HEADER.bi_clr_used:neq(0) then
        object.valid = false
        error("c_BMP: Only non color map bitmaps are supported")
    end
    if BITMAPV4HEADER.bv4_cs_type:neq("BGRs") or BITMAPV4HEADER.bv4_cs_type:neq(" niW") then
        object.valid = false
        error("c_BMP: Only standard color space is supported")
    end
    
    object.data.DIBHEADER = BITMAPV4HEADER
    object.data.DIBHEADERTYPE = header_types.BITMAPV4HEADER
    object.valid = true
end

--Read DIBHEADER version: 5
local function readBITMAPV5HEADER(handle, object)
    if type(handle) == "userdata" then
        local buff = handle:read(120)
    else
        local buff = handle(19,138)
    end
    local BITMAPV5HEADER = {
        bi_size = uint(124),
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
    if BITMAPV5HEADER.bi_bit_count:neq(32) then 
        object.valid = false
        error("c_BMP: Only 32 and 24 bits per pixel format is supported for BITMAPV5HEADER")
    end
    if BITMAPV5HEADER.bi_compression:neq(0) then
        object.valid = false
        error("c_BMP: Only non compressed pixel array are supported")
    end
    if BITMAPV5HEADER.bi_clr_used:neq(0) then
        object.valid = false
        error("c_BMP: Only non color map bitmaps are supported")
    end
    if BITMAPV5HEADER.bv4_cs_type:neq("BGRs") or BITMAPV5HEADER.bv4_cs_type:neq(" niW") then
        object.valid = false
        error("c_BMP: Only standard color space is supported")
    end
    
    object.data.DIBHEADER = BITMAPV5HEADER
    object.data.DIBHEADERTYPE = header_types.BITMAPV5HEADER
    object.valid = true
end

local function readPIXELARRAY(handle, object, source)
    
end

--[[
    All data must be presented as strings
]]

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