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

--arg = {bmpfile,icons,}
function get_toolbarBmpname(arg)
	local dstFile = arg.bmpfile
	make_toolbarBmpfile{dstFile =dstFile,icons =  arg.icons}
	return dstFile
end

function get_defaultBmp()
	return 'default.bmp'
end

------------------------------------------------------------------
--
save_bmpImage = function(file)
	local image = iup.LoadImage(file)
	iup.SaveImage(image,file, 'BMP')
end


--arg = {dstFile = ,icons = }
function make_toolbarBmpfile(arg)
	if sysDisk.file_exist(arg.dstFile)  then return end  
	local bmps = {}
	local str = 'convert +append '
	local file;
	for _,val in ipairs(arg.icons) do
		if type(val) == 'string' and val ~= '' and sysDisk.file_exist(val) then 
			str = str .. ' ' .. '\"' .. val .. '\"'
		else 
			str = str .. ' ' .. '\"' .. get_defaultBmp()  .. '\"'
		end
		
	end	
	str = str .. ' ' .. get_defaultBmp()
	str = str .. ' ' .. arg.dstFile

	execute(str)
	
	local image = iup.LoadImage(arg.dstFile)
	if image then 
		iup.SaveImage(image,arg.dstFile, 'BMP')
	end
end

