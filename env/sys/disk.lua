

local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local CODE  =  require 'sys.code'

local lfs = require 'lfs'
local require =require

local table = table
local string = string
local error =error
local print = print
local execute = os.execute
local remove = os.remove
local loadfile = loadfile
local open = io.open
local ipairs = ipairs
local tostring = tostring
local pairs = pairs
local type = type
local rename = os.rename

_ENV = _M

function file_save(file,data,isReturn)
	if not file or not data then error('function "save_file" parameter error !') end
	CODE.save{key = 'db',file = file,data = data}
end

file_delete = remove

function file_read_table(file)
	if file_exist(file) then 
		local info,t = {}
		local f = loadfile(file,'bt',info)
		if f then 
			t = f()
		end
		return info.db or t
	end
end

local function file_read_string(file)
	local f = open(file,'rb')
	if not f then return end 
	local str = f:read("*all") or '';
	f:close()
	return str
end

function file_read(file,isString)
	if isString  then 
		return file_read_string(file)
	else 
		return file_read_table(file)
	end
end


--file = 'a/b/c.lua' or a/b
function file_exist(file)
	local t =  lfs.attributes(file)
	if t then 
		return true 
	end
	return
end


--file = 'c/b/e.lua'
--支持绝对路径和相对路径的加载
function file_require(file)
	local str = file;
	if file_exist(file) then 
		str = string.gsub(str,'/','.')
		local mod = require (string.sub(str,1,-5))
		return mod
	end
end

--[[
Test:a file attributes
return {
	dev=2
	ino=0
	mode='file'
	nlink=1
	uid = 0
	gid=0
	rdev=2
	access=1497872883
	modification=1497872883
	change=1497872883
	size = 39
};
]]
function file_info(file)
	-- return LFS.get_info(file)
end

--[[
	return {
		change = attr.modification,--最新数据修改时间
		status = attr.change,--最新状态改变时间
		access = attr.access,--最新使用时间
	} 
]]
function file_time(file)
	-- return LFS.get_time(file)
end

function file_mtime(file)
	-- return LFS.get_time(file).change
end

--剪切文件
function file_shear(src,dst)
	src = string.gsub(src,'/','\\')
	dst = string.gsub(dst,'/','\\')
	execute('move /y ' ..  '\"' .. src  .. '\"' .. ' '.. '\"' .. dst .. '\"')
end

function file_copy(src,dst)
	src = string.gsub(src,'/','\\')
	dst = string.gsub(dst,'/','\\')
	if file_exist(src) then 
		execute('copy /y \"' .. src  .. '\" \"' .. dst .. '\"')
		return true
	end
end

--调用windows 打开命令
function file_open(file)
	file = string.gsub(file,'/','\\')
	if file_exist(file) then
		execute("start  \"\" " .. "\"" .. file .. "\"")
		return true
	end
end

-- file or directory change mode 
--use dos cmd : ATTRIB
--disk  =; dir : c:/a/b or file: c:/a/b.lua
--attrib = ;dos cmd
function disk_mode(disk,attrib)
	disk = string.gsub(disk,'/','\\')
	attrib = attrib or ''
	if file_exist(disk) then
		execute("ATTRIB  " .. attrib .. " " .. "\"" .. disk .. "\" /s /d ")
		return true
	end
end


--src = a/b/c/,dst = e/f/g/
--result:e/f/g/*.*
--移动目录到另一个目录下
function dir_shear(src,dst)
	src  =string.gsub(src,'/','\\')
	if #src >3 then
		src = string.sub(src,1,-2)
	end
	dst  =string.gsub(dst,'/','\\')
	if #dst >3  then 
		dst = string.sub(dst,1,-2)
	end
	lfs.mkdir(dst)
	execute('xcopy  "' .. src .. '" "' .. dst .. '" /E /Q /Y' )
	execute('rd /s /q "' .. src .. '"' )
end

--path = a/b/c/,src = d ,dst = e 
function file_rename(path,srcName,dstName,move)
	local src = path .. srcName
	local dst = path .. dstName
	if move then 
		return file_shear(src,dst)
	else 
		return rename(src,dst)
	end
	
end

function dir_copy(src,dst)
	src  =string.gsub(src,'/','\\')
	if #src >3 then
		src = string.sub(src,1,-2)
	end
	dst  =string.gsub(dst,'/','\\')
	if #dst >3  then 
		dst = string.sub(dst,1,-2)
	end
	lfs.mkdir(dst)
	execute('xcopy  "' .. src .. '" "' .. dst .. '" /E /Q /Y' )
end

--dir = c:/a/b/
function dir_delete(dir)
	dir = string.sub(dir,1,-2)
	dir = string.gsub(dir,'/','\\')
	return execute('rd /s /q "' .. dir .. '"' )
end

-- 打开资源管理器文件夹所在位置
--dir = a/b/c
function dir_open(dir)
	dir = string.match(dir,'(.+)/')
	dir = string.gsub(dir,'/','\\')
	if file_exist(dir) then
		execute("explorer   " .. "\"" .. dir .. "\"")
	end
end


--]]
function mkdir(dir)
	if not lfs.attributes(dir) then  
		lfs.mkdir(dir)
	end
end

-- path = 'a/b/c/' or 'c:/a/b/' ,name = 'd'
function mkdir_(path,name)
	if not path or (path == '') or not name then return end
	if  not  lfs.attributes(path) then 
		local dir=path ..name
		mkdir(dir)
		return true
	end
end

--path ='a:/c/' or 'c/b/'
function mkdir_rec(path)
	if lfs.attributes(path) then return end 
	local str,disk = path
	if string.find(path,':/') then
		disk,str = string.match(path,'[^/]+/'),string.match(path,'/(.+)')
	end
	local temp = disk or ''
	string.gsub(str,'[^/]+',function(name)
		mkdir_(temp,name) 
		temp = temp .. name .. '/'
	end
	)
end

function PrintTable( tbl , level, filteDefault)
  local msg = ""
  filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
  level = level or 1
  local indent_str = ""
  for i = 1, level do
    indent_str = indent_str.."  "
  end

  print(indent_str .. "{")
  for k,v in pairs(tbl) do
    if filteDefault then
      if k ~= "_class_type" and k ~= "DeleteMe" then
        local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
        print(item_str)
        if type(v) == "table" then
          PrintTable(v, level + 1)
        end
      end
    else
      local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
      print(item_str)
      if type(v) == "table" then
        PrintTable(v, level + 1)
      end
    end
  end
  print(indent_str .. "}")
end


--file = 'a/b'
function dir_exist(dir)
	local t =  lfs.attributes(dir)
	if t then 
		return 'true' 
	end
	return
end

------------------------2018年12月20日----------------------------------------------------------------
--path = '.../' or 'c:/.../'
--[[
return {
	{
		name = 'a'; --文件夹名称。
		‘b’; --文件名称
		...
	};
	‘c’;--文件名称
	...
}
--]]
function read_dir(path,total,dat)
	local file;
	local dat = dat or {}
	for line in lfs.dir(path) do 
		if line ~= '.' and line ~= '..' then 
			file = path .. line
			if lfs.attributes(file,'mode') == 'directory' and total then 
				dat[#dat+1] ={name = line}
				read_dir(file .. '/',total,dat[#dat])
			else
				dat[#dat+1] = line
			end
		end
	end
	return dat
end

function get_childCount(folder)
	return #read_dir(folder)
end