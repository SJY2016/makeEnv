local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M


local luaext = require 'luaext'
local crypto = require"crypto"
local sysCode  =  require 'sys.code'
local lfs = require 'lfs'

local lower = string.lower
local match = string.match
local gsub = string.gsub
local open = io.open
local execute = os.execute
local remove = os.remove
local rename = os.rename


local assert = assert
local type = type
local print = print
local require = require
local string = string
local pairs = pairs
local getmetatable = getmetatable
local setmetatable = setmetatable


_ENV = _M

---------------------------------------------------------------------
--copy table
function copy(obj,seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({},getmetatable(obj))
	s[obj] = res
	for k,v in pairs(obj) do
		res[copy(k,s)] = copy(v,s)
	end
	return res
end

---------------------------------------------------------------------
--hash string
function hash_string(str)
	local dig = crypto.digest;
	if not dig then return nil end
	local d = dig.new("sha1");
	local s = d:final(str);
	d:reset();
	return s;
end

function hash_file(file)
	if type(file)~='string' then return end
	local str = sysDisk.file_read(file,true)
	if not str or str == '' then return '0kb' end 
	return hash_string(str);
end

---------------------------------------------------------------------
--modname 参数值分两种情况针对同一个文件app/greenmark/element/element.lua
--正常情况: app.greenmark.element.element
--模型加载：app/greenmark/element/element
function get_path(modname)
	
	assert(type(modname) == 'string')
	-- print(modname)
	modname = gsub(modname,'/','.')
	modname = gsub(modname,'\\','.')
	local rpath = lower(match(modname,'(.+%.)[^%.]+'))
	local path = gsub(rpath,'%.','/')
	return rpath,path
end

---------------------------------------------------------------------
-- file op api
function file_save(file,data,isReturn)
	if not file or not data then error('function "save_file" parameter error !') end
	sysCode.save{key = 'db',file = file,data = data}
end

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
---------------------------------------------------------------------