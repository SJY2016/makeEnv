--[[
/*
*Author:Sun JinYang
*Begin:2017年12月13日
*Description:
*	此文件用来处理语言版本相关功能。
*Record:（Time Content）
*		2018年4月2日 将语言改为类的模式
*/
--]]
--[[
数据结构：
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysDisk = require 'sys.disk'
local sysSetting = require 'sys.setting'
local lfs = require 'lfs'
local luaext = require 'luaext'

local ipairs = ipairs
local pairs = pairs
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local print = print
local assert = assert
local table = table
local string = string

_ENV = _M

local CurVersion;
local CurVersionList;
local IdsTab;
--------------------------------------------------------------
local Lang = {}
Class = Lang
--------------------------------------------------------------
function Lang:new(groupName)
	assert(type(groupName) == 'string')
	local t = {}
	setmetatable(t,self);
	self.__index = self;
	t.groupName= groupName
	return t
end

function Lang:close()
	-- return CurVersion
end

function Lang:get_id_name(id)
	-- return CurVersion
	return id
end

--------------------------------------------------------------

function  Lang:init_curVersion(val)
	CurVersion = type(val) == 'string' and val or 'en'
end
function  Lang:init_versionList(val)
	CurVersionList = type(val) == 'table' and val 
end
function  Lang:init_ids(val)
	if type(val) == 'table' then 
		
	end 
end

function Lang:get_ver()
	return CurVersion or 'zh'
end

--------------------------------------------------------------
function Lang:init_confDat(val)
	local dat;
	if type(val) == 'string' then 
		dat = sysDisk.file_read(val)
	elseif type(val) == 'table' then 
		dat = val
	end
	if type( dat ) ~= 'table' then return end 
	self:init_curVersion(dat.version)
	self:init_versionList(dat.versionList)
	self:init_ids(dat.ids)
	return t
end

sysSetting.reg_cbf(Lang.init_confDat)