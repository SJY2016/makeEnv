local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local classDlg = require 'sys.iup.dlg'.Class
local classLang = require 'sys.lang'.Class
local iup = iup
local message = iup.Message

local type = type
local string = string
local setmetatable = setmetatable

_ENV = _M

setmetatable(_M,{__index = iup})

iup.Message = function(str1,str2)
	local lang = classLang:new('sys/iup')
	local val = message(lang:get_id_name(str1) or str1,lang:get_id_name(str2) or str2)
	lang:close()
	return val
end

local function turn_path(path)
	path = string.match(path,'(.+)%/')
	path = string.gsub(path,'/','\\')
	return path
end

--arg = {path,...}  --path:a/b/
open_dir = function(arg)
	arg = arg or {}
	local path = arg.path and turn_path( arg.path) or ''
	local filedlg = iup.filedlg{
		DIALOGTYPE = 'DIR',
		DIRECTORY = path;
		PARENTDIALOG=arg.parentdlg;
	}
	filedlg:popup()
	local val = filedlg.value
	if not val then return end 
	val =string.gsub(val,'\\','/')
	if  string.sub(val,-1,-1) ~= '/' then 
		val =val .. '/'
	end
	return val
end
--arg = {path,filter = '',...}  --path:a/b/
open_file = function(arg)
	arg = arg or {}
	local path = arg.path and turn_path( arg.path) or ''
	local filedlg = iup.filedlg{
		DIALOGTYPE = 'OPEN',
		DIRECTORY = path,
		MULTIPLEFILES = 'YES',
		EXTFILTER  = arg.extfilter; 
		--定义过滤问价规则样式为"FilterInfo1|Filter1|FilterInfo2|Filter2|...". 
		--Example: "Text files|*.txt;*.doc|Image files|*.gif;*.jpg;*.bmp|". 
		FILE = arg.file;
		PARENTDIALOG=arg.parentdlg;
	}
	filedlg:popup()
	local count = filedlg.MULTIVALUECOUNT
	local files = {}
	if count  then 
		if count == 0 then return end 
		local path;
		for i = 1,count do 
			if i == 1 then 
				path =  filedlg['MULTIVALUE' .. (i -1)]
				path = string.sub(path,-1,-1) == '\\' and path or (path .. '\\')
				path = string.gsub(path,'\\','/')
			else 
				local filename = filedlg['MULTIVALUE' .. (i -1)]
				files[#files+1] = {file = path ..  filename,name =filename }
			end
		end
	else 
		local value  = filedlg.value
		if not value then return end 
		value = string.gsub(value,'\\','/')
		files[#files + 1] = {file = value,name =string.match(value,'.+/([^/]+)') }
	end 
	return files
end
--arg = {path,...}  --path:a/b/
save_file = function(arg)
	arg = arg or {}
	local path = arg.path and turn_path( arg.path) or ''
	local filedlg = iup.filedlg{
		DIALOGTYPE = 'SAVE',
		DIRECTORY = path,
		PARENTDIALOG=arg.parentdlg;
	}
	filedlg:popup()
	return filedlg.value
end

-- return iup