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

local sysTools = require 'sys.tools'
local sysDisk = require 'sys.disk'
local sysSetting = require 'sys.setting'
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

local init_keywordDat;
local keywordDat;
--------------------------------------------------



init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	db = sysTools.deepcopy(dat)
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
							local file = fileName .. '.lua'
							local mod = sysDisk.file_require(file)
							if mod and mod[funName] then 
								modFun = mod[funName]
							end
						elseif cur.file then 
							local file = cur.file
							local mod = sysDisk.file_require(file)
							if mod and mod[cur.value] then 
								modFun = mod[cur.value]
							end
							
						elseif tab.file then 
							local file = tab.file
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
end

get_keywordDat  = function(key)
	if not keywordDat then return end
	if not key then return end
	return type(keywordDat[key]) == 'table' and keywordDat[key]
end


sysSetting.reg_cbf('keyword',init_keywordDat)
--]]
--------------------------------------------------

