--[[
/*
*Author:Sun JinYang
*Begin:2018年9月14日
*Description:
*	此文件用来加载和获取系统配置文件的数据。
*Import Update Record:（Time Content）
*/
--]]
--[[
注册回调函数中 key 可接受的值有：
	page：
	menu:
	toolbar:
	lang:
	cmd:
	keyword:
	
--]]

local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysDisk = require 'sys.disk'

local type = type
local print = print
local setmetatable =setmetatable
local table = table
local string = string
local pairs = pairs
local ipairs = ipairs
local assert = assert

_ENV = _M

-------------------------------------------------------------------------------------
local file = 'conf.lua'
local get_db;
local save_db;
local init_db;
-------------------------------------------------------------------------------------
local cbfs = {}

init = function() init_db() end

function update()
	local dat = get_db()
	local loads = dat.loads
	for _,mod in ipairs(loads) do 
		local val = dat[mod]
		if val and  cbfs[mod] then 
			local tab = val;
			if type(val) == 'string' then 
				tab = sysDisk.file_read(val)
			end
			assert(type(tab) == 'table','请检查\"' .. mod .. '\"数据是否正确！')
			if tab then 
				cbfs[mod](tab)
			end
		end
	end
	for fun,key in pairs(cbfs) do 
		if type(fun) == 'function' then 
			if type(key) == 'string' then 
				local val = dat[key]
				local tab = val;
				if type(val) == 'string' then 
					tab = sysDisk.file_read(val)
					assert(type(tab) == 'table','请检查文件“' .. val .. '”数据是否正确！')
				end
				if tab then 
					fun(tab)
				end
			end
		end		
	end
end

function reg_cbf(key,fun)
	if type(fun) == 'function' and type(key) == 'string' then 
		if not cbfs[key]   then 
			cbfs[key]  = fun
		end
	end
end

function delete_cbf(key)
	cbfs[key]  = nil
end
-------------------------------------------------------------------------------------

local function load_db()
	local db;
	local function init()
		db = sysDisk.file_read(file) or {}
		return db
	end
	return init,function ()
		return db
	end,function(dat)
		if type(dat) == 'table' then db = dat  else return end 
		sysDisk.file_save(file,db,true)
	end
end

init_db,get_db,save_db =  load_db()