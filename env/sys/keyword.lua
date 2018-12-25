--[[
/*
*Author:Sun JinYang
*Begin:2018年08月03日
*Description:
*	这个文件用来控制已经做好的成分材质种类。
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
	toolbar & menu :
		name:值为string类型，设置keyword对应显示的名称。
		remark:值为string类型，设置的备注信息。
		action:值为function类型，点击触发执行的函数。
		view:值为boolean类型，view环境下点击可用。缺省值为true
		frame:值为boolean类型，非view环境下点击可用。缺省值为true
		image:值为string类型，图标的名称。比如:'a.png'
		enable:值为boolean类型或者返回boolean值的function类型，按钮是否允许点击的状态（激活还是置灰的状态）。缺省值为true
		checkbox:值为boolean类型，设置工具条按钮的风格样式为按下后不直接弹起。缺省为按下后立即弹起
		shortcut:
		hotkey:值为strig类型，响应热键消息
	leftDlg :
	
函数keys：
	onLoad:
	onUnload;
	onAction:
	action:
	
		
注意：
	存在系统app和插件两种形式，系统级app的数据由app加载时动态添加，而插件在安装后的数据则需要加载db数据文件得到。app加载的数据不需要任何变化也不存储，而由db文件引入的数据需要将action对应的字符串转换成真实的函数进行处理。
接口函数：
使用方式：
local cur = require ''.Class:new(oldTab or nil)
cur: ...
数据样式：
	db = {
		key1 = {action = '',name =,view =,...};
		key2 = {action = '',name =,view =,...};
	}
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local rpath,path = require 'sys.tools'.get_path(modname)
local sysDisk = require (rpath .. 'disk')
local lfs = require 'lfs'


local setmetatable = setmetatable
local type =type
local print =print
local assert = assert
local ipairs = ipairs
local pairs = pairs
local next = next
local string = string
local sub = string.sub
local sort = table.sort
local unpack =  table.unpack
local error = error
local table = table


_ENV = _M

local objPlugin = classPlugin:new()
local confPath = 'config/plugins/'
local fileUser = confPath .. 'keywords.lua'


--------------------------------------------------

local init_db;
local update_db;
local get_db;
local save_db;

local init_keywordDat;
local update_keywordDat;


--------------------------------------------------

local Keyword = {} 
Class = Keyword

function Keyword:new(t)
	t = t or {}
	setmetatable(t,self)
	self.__index = self
	return t
end


--self:get_all;
--self:get_keywordDat
--self:add_keyword;

--------------------------------------------------
--[[
	db = {
		key1 = {pluginName = ,action = '文件 +.函数名' 或者'函数名' + file属性,file = '',}
		...;
	}	
--]]
init_db = function()
	local db;
	return function()
		db = sysDisk.file_read(fileUser) or {}
		update_keywordDat()
		return db
	end,function()
		return db or update_db()
	end,function(db)
		sysDisk.file_save(fileUser,db)
		update_db()
	end
end

update_db,get_db,save_db = init_db()
--------------------------------------------------
--注意keywordDat数据一部分是来自于文件中（插件部分，key值对应的是true），一部分来自系统加载app得到的（key值对应的是数据表）。

local function get_iconFile(tab,key)
	--查找插件目录下的文件
	local curFile = objPlugin:get_installedPluginPath() .. tab[key]
	if  sysDisk.file_exist(curFile) then 
		return curFile
	end
	--查找系统路径
	curFile =tab[key]
	if  sysDisk.file_exist(curFile) then 
		return curFile
	end
	return tab[key]
end

local function deepcopy(tab,newTab)
	if type(tab) ~= 'table' then return {} end 
	local newTab = newTab or {}
	for k,v in pairs(tab) do 
		if type(v) ~= 'table' then 
			newTab[k] = v
		else 
			newTab[k] = {}
			deepcopy(v,newTab[k])
		end
	end
	return newTab
end


init_keywordDat = function()
	local keywordDat;
	return function()
		keywordDat  = keywordDat or {}
		local db = get_db()
		db = deepcopy(db)
		for k,keyDat in pairs(db) do 
			keywordDat[k] = {}
			setmetatable(keywordDat[k],
				{
					__index = function(tab,key)
						local cur = keyDat[key]
						if not cur then return end 
						if type(cur) == 'table' and cur.type == 'function' then 	
							local tab = keyDat;
							local modFun;
							if string.find(cur.value,'%.') then 
								local fileName,funName =string.match(cur.value,'(.+)%.'),string.match(cur.value,'.+%.([^%.]+)')
								local file = objPlugin:get_installedPluginPath(tab.plugin) .. fileName .. '.lua'
								local mod = sysDisk.file_require(file)
								if mod and mod[funName] then 
									modFun = mod[funName]
								end
							elseif cur.file then 
								local file = objPlugin:get_installedPluginPath(tab.plugin) .. cur.file
								local mod = sysDisk.file_require(file)
								if mod and mod[cur.value] then 
									modFun = mod[cur.value]
								end
								
							elseif tab.file then 
								local file = objPlugin:get_installedPluginPath(tab.plugin) .. tab.file
								local mod = sysDisk.file_require(file)
								if mod and mod[cur.value] then 
									modFun = mod[cur.value]
								end
							end
							if cur.exe and modFun then 
								keyDat[key] =modFun()
							elseif modFun then 
								keyDat[key] =modFun
							else 
								keyDat[key] = function() error('Fuction Missing !') end
							end
							return keyDat[key] 
						end
						return cur
					end
				}
			)
		end	
		return keywordDat
	end,function(self,dat,delete)
		if not keywordDat then update_keywordDat() end
		if not dat.keyword then return end 
		if delete then 
			keywordDat[dat.keyword] = nil
		else 
			keywordDat[dat.keyword] = dat
		end
		return 
	end,function(self,key)
		if not keywordDat then update_keywordDat() end
		if not key then return end
		return type(keywordDat[key]) == 'table' and keywordDat[key]
	end,function(self)
		if not keywordDat then update_keywordDat() end
		return keywordDat
	end
end

update_keywordDat,Keyword.add_keyword,Keyword.get_keywordDat,Keyword.get_all = init_keywordDat()
--------------------------------------------------

