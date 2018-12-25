--[[
/*
*Author:Sun JinYang
*Begin:2018年9月14日
*Description:
*	此文件夹用来控制使用此类的数据文件中数据的存取
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
	defaultFile:值为string类型，通常表示为系统数据存放的配置文件。
	userFile：值为string类型，通常表示为用户通过界面操作得到的数据存放的配置文件。
	fileDat:值为table类型，文件包含的数据。
接口函数：
使用示例：
local cur = require ''.Class:new{userFile = '',defaultFile = '',}
cur:get_fileDat()
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

_ENV = _M

-------------------------------------------------------------------------------------
local File = {}
Class = File
-------------------------------------------------------------------------------------
--t = {userFile,defaultFile,init}
function File:new(t)
	t  = t or {}
	setmetatable(t,self)
	self.__index = self
	if t[get_init()] then 
		t.init_db,t.get_fileDat,t.get_db,t.save_fileDat = t:init()	
		t[get_init()] = nil
	end
	return t
end

function get_init()
	return '_INIT_'
end
-------------------------------------------------------------------------------------
--虚函数


function File:end_init(...)  print('File end_init') end
function File:end_save(...)  print('File end_save') end

function File:init_db(...)  print('init_db') end
function File:get_fileDat(...)  print('get_fileDat') end
function File:save_fileDat(...)  print('save_fileDat') end

-------------------------------------------------------------------------------------
function File:init_defaultFile(file)
	self.defaultFile = file
end

function File:init_userFile(file)
	self.userFile = file
end

function File:set_dat(dat)
	self.fileDat = dat
end

function File:saveAs(file,dat)
	if type(file) ~= 'string' then return end
	dat = dat or self.fileDat
	sysDisk.file_save(file,dat)
end
-------------------------------------------------------------------------------------
function File:get_keyDat(key)
	local dat = self:get_fileDat()
	if key and dat and dat[key] then 
		return dat[key]
	end
end

function File:save_keyDat(key,value)
	local dat = self:get_db() or {}
	if key and value then 
		dat[key] = value
		return self:save_fileDat{dat = dat,noUpdate = true}
	end
end
-------------------------------------------------------------------------------------
function File:deepCopy(tab,newTab)
	if type(tab) ~= 'table' then return end 
	local newTab = newTab or {}
	for k,v in pairs(tab) do 
		if type(v) == 'table' then 
			newTab[k] = {}
			self:deepCopy(v,newTab[k])
		else 
			newTab[k] = v
		end
	end
	return newTab
end

function File:init()
	local db;
	local fileDat;
	return function(self)	
		if self.userFile then 
			db = sysDisk.file_read(self.userFile)
		end
		if not db and self.defaultFile then 
			db = sysDisk.file_read(self.defaultFile)
		end
		db = type(db) == 'table' and db or {}
		self:end_init()
		fileDat = self:deepCopy(db)
	end,function(self)
		if not fileDat then 
			 self:init_db()
		end
		return fileDat
	end,function(self)
		if not db then 
			 self:init_db()
		end
		return db
	end,function(self,arg)--arg = {dat = ,file =,update = true}
		if type(arg) ~= 'table' then return end 
		local file = arg.file  or  self.userFile  or self.defaultFile
		local dat = arg.dat or db
		if file and dat then 
			sysDisk.file_save(file,dat)
		end
		self:end_save()
		self:init_db()
	end
end

-- File.init_db,File.get_fileDat,File.get_db,File.save_fileDat = File:init()	

