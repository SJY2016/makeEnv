--[[
/*
*Author:Sun JinYang
*Begin:2018年07月18日
*Description:
*	这个文件用
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
	
接口函数：
使用方式：
local cur = require ''.Class:new(oldTab or nil)
cur: ...
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysDisk = require 'sys.disk'

local lfs = require 'lfs'
local iup = IUP

local sub = string.sub
local string = string
local setmetatable = setmetatable
local print =print
local assert = assert
local type =type
local execute = os.execute
local ipairs = ipairs
local remove = os.remove


_ENV = _M



local defaultSize = 16

--------------------------------------------------------------------
-- local make_toolbarBmpfile;
--------------------------------------------------------------------

local Res = {}
Class =Res

function Res:new(t)
	t = t or {}
	setmetatable(t,self)
	self.__index = self
	return t
end

--arg = {name,icons,--size=,}
function Res:get_toolbarBmpname(arg)
	local size = arg.size or defaultSize
	local name = arg.name or 'toolbar'
	local dstFile =  toolbarUserPath  .. name .. toolbarDefaultFileType
	self:make_toolbarBmpfile{dstFile =dstFile,iconPath =toolbarDefaultPath .. size .. '/',icons =  arg.icons,name = name}
	return dstFile
end

function Res:get_defaultBmp()
	return 'default.bmp'
end

function Res:get_toolbarDefaultBmp(size)
	size = size or defaultSize
	return toolbarDefaultPath  .. size.. '/default.bmp'
end

function Res:get_toolbarBtnNameIcon(name,size)
	size = size or defaultSize
	return toolbarDefaultPath .. size .. '/' .. name
end

function Res:init_createBmpStatus(status)
	self.createBmp = status
	--可以考虑将toolbar中的图片完全删除
end

function Res:clear_toolbarBmps()
	local path = toolbarUserPath
	for line in lfs.dir(path) do 
		if line ~= '.' and line ~= '..' then 
			local file = path .. line
			if string.match(line , '%.bmp') and lfs.attributes(file,'mode') == 'file' then 
				remove(file)
			end
		end
	end
end

function Res:get_toolbarDefaultPath()
	return toolbarDefaultPath .. defaultSize .. '/'
end

--val = {plugin = ,icon = }
function Res:get_pluginIcon(val)
	local file = objPlugin:get_installedPluginPath(val.plugin) .. val.icon
	if not sysDisk.file_exist(file)  then 
		file = self:get_toolbarDefaultPath() .. val.icon
	end
	return file
end

-------------------------------------------------------------------
--
save_bmpImage = function(file)
	local image = iup.LoadImage(file)
	iup.SaveImage(image,file, 'BMP')
end

--arg = {dstFile = ,iconPath = ,icons = }
function make_toolbarBmpfile(arg)
	
	if sysDisk.file_exist(arg.dstFile) and not self.createBmp then return end  
	local bmps = {}
	local str = 'convert +append '

	if sysDisk.file_exist(arg.dstFile) then 
		remove(arg.dstFile)
	end
	
	
	for _,val in ipairs(arg.icons) do
		local file;
		if type(val) == 'table' and val.plugin then
			file = self:get_pluginIcon(val)
		elseif type(val) == 'string' then 
			if string.find(val,'/') then 
				file = val
			else 
				file = arg.iconPath .. val
			end	
		end
		
		if  not file or not sysDisk.file_exist(file) or not  lfs.attributes(file,'mode') == 'file' then 
				file = arg.iconPath ..  Res:get_defaultBmp()
		end
		str = str .. ' ' .. '\"' .. file .. '\"'
	end	
	str = str .. ' ' .. self:get_toolbarDefaultBmp(size)
	str = str .. ' ' .. arg.dstFile

	execute(str)
	
	local image = iup.LoadImage(arg.dstFile)
	if image then 
		iup.SaveImage(image,arg.dstFile, 'BMP')
	else 
		local file = 'cfg/bmp/' .. arg.name .. '.bmp'
		if not sysDisk.file_exist(file) then 
			file = 'cfg/bmp/toolbar1.bmp'	
		end
		sysDisk.file_copy(file,arg.dstFile)
	end
end

