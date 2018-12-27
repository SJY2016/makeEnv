--[[
/*
*Author:Sun JinYang
*Begin:2018年12月27日
*Description:
*	这个文件用来处理不同模块 加载时keyword数据
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
	toolbar & menu :
		remark:值为string类型，设置的备注信息。
		view:值为true 时，有视图存在时，响应 onClick 函数。
		frame:值为true 时，视图不存在时，响应 onClick 函数。
		file:值为string 类型，响应函数存放的文件（可以省略直接在action中进行设置）。
		icon:值为string类型，图标文件路径。比如:'res/a.bmp' ,。
			注意：通常工具条按钮的图标为16x16的bmp 格式的文件.
		action:值可能存在的类型有：function、string、或者table,设置响应函数。
			注意：string类型 函数的名称或者 包含文件路径函数名（带文件路径的函数所在的文件必须为.lua文件）。
				例如 
					带路径的函数字符："a/b/action.onClick"代表a/ b/文件夹下的action.lua 文件中包含可供外部调用的onClick函数
				等同于
					file属性和 action 属性合作使用：file = "a/b/action.lua"  action = 'onClick'
						
			
		enable:值为boolean类型或者返回boolean值的function类型，按钮是否允许点击的状态（激活还是置灰的状态）。缺省值为true
		-- checkbox:值为boolean类型。缺省为按下后立即弹起,待添加。
		-- shortcut:,待添加
		-- hotkey:值为strig类型，响应热键消息,待添加
	leftDlg :
		hwnd :参考action，函数需要返回iup 控件对。通常为 iup.frame 、iup.vbox
		onInit 参考action，初始化数据回调函数
		onLoad 参考action，加载 hwnd 前函数处理
		onUnload 参考action，卸载 hwnd 后函数处理。
数据样式：
	local keywords = {
		['Page'] = { --page : left dlg
			tabtitle = 'GreenMark';
			file = 'browser/main.lua';
			hwnd=  {type = 'function',value ="get_hwnd"}; 
			onInit=  {type = 'function',value ="on_init"}; 
			-- onLoad=  {type = 'function',value ="on_load"}; 
			onUnload=  {type = 'function',value ="on_unload"}; 
		};
		['Menu'] = {
			view = true;
			frame = true;
			action = "action.new_file";
		};
		['Toolbar'] = {
			view = true;
			frame = true;
			icon = 'res/save.bmp';
			action ="action.open_file";
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


local functionKeys = {
	action = true;
	hwnd = true;
	onInit = true;
	onLoad = true;
	onUnload = true;
}

init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	local db = dat 
	for k,keyDat in pairs(db) do 
		keywordDat[k] = {}
		setmetatable(keywordDat[k],
			{
				__index = function(tab,key)
					local val = keyDat[key]
					local file = keyDat.file
					if not val then return end 
				
					if functionKeys[key] then	
						if type(val) ~= 'table' and type(val) ~= 'function' and type(val) ~= 'string'  then return val end 
						local mod,fun;
						if type(val) == 'function' then 
							fun = val
						else
							local action = type(val) == 'table' and val.action or val
							local useFile =  type(val) == 'table' and val.file or file
							if type(action) == 'function' then 
								fun = action
							else 
								local actionFile,actionCmd = string.match(action,'([^%.]+)'),string.match(action,'%.(.+)') --action 字符串中可能包含文件信息
								if actionCmd then 
									--如果actionCmd 存在 则意味着该字符串的样式为 "str1.str2" str2中可能继续包含“.”str1中可能包含‘/’
									mod =  sysDisk.file_require(actionFile .. '.lua')
									--注意此时有可能str1并不代表文件，有可能也是命令的一部分.此时，如果mod存在则系统认为必定是文件路径,所以开发人员在开发时避免使用容易引起歧异的字符。
								end
								if not mod and useFile then 
									--处理mod 不存在的情况，如果有优先使用table内的file 否则使用上一层定义的file属性值。而具体命令则使用完整的action对应的字符。
									mod =  sysDisk.file_require(useFile)
									actionCmd = action
								end
								if mod and actionCmd then 
									fun = type(mod[actionCmd]) == 'function' and mod[actionCmd]
								end
							end
						end
						
						if fun then 
							-- if type(val) == 'table' and val.exe then 
								-- fun = fun()
							-- end
							keyDat[key] =fun
						else 
							keyDat[key] = function() error('Fuction Missing !') end
						end
						return keyDat[key] 
					end
					return val
				end
			}
		)
	end	
end

get_keywordDat  = function(key)
	if not keywordDat then return end
	if not key then return end
	if  type(keywordDat[key]) == 'table'  then 
		return keywordDat[key]
	end
end


sysSetting.reg_cbf('keyword',init_keywordDat)
--]]
--------------------------------------------------
--[===[
--[[
/*
*Author:Sun JinYang
*Begin:2018年12月27日
*Description:
*	这个文件用来处理不同模块 加载时keyword数据
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
	toolbar & menu :
		remark:值为string类型，设置的备注信息。
		view:值为true 时，有视图存在时，响应 onClick 函数。
		frame:值为true 时，视图不存在时，响应 onClick 函数。
		file:值为string 类型，响应函数存放的文件（可以省略直接在action中进行设置）。
		icon:值为string类型，图标文件路径。比如:'res/a.bmp' ,。
			注意：通常工具条按钮的图标为16x16的bmp 格式的文件.
		action:值为function类型或者string类型,点击触发执行的函数。
			注意：string类型 函数的名称或者 包含文件路径函数名（带文件路径的函数所在的文件必须为.lua文件）。
				例如 
					带路径的函数字符："a/b/action.onClick"代表a/ b/文件夹下的action.lua 文件中包含可供外部调用的onClick函数
				等同于
					file属性和 action 属性合作使用：file = "a/b/action.lua"  action = 'onClick'
						
			
		enable:值为boolean类型或者返回boolean值的function类型，按钮是否允许点击的状态（激活还是置灰的状态）。缺省值为true
		-- checkbox:值为boolean类型。缺省为按下后立即弹起,待添加。
		-- shortcut:,待添加
		-- hotkey:值为strig类型，响应热键消息,待添加
	leftDlg :
		onInitDlg
		onInitDat
		onLoad
		onUnload
数据样式：
	local keywords = {
		['Page'] = { --page : left dlg
			tabtitle = 'GreenMark';
			file = 'browser/main.lua';
			hwnd=  {type = 'function',value ="get_hwnd"}; 
			onInit=  {type = 'function',value ="on_init"}; 
			-- onLoad=  {type = 'function',value ="on_load"}; 
			onUnload=  {type = 'function',value ="on_unload"}; 
		};
		['Menu'] = {
			view = true;
			frame = true;
			action = "action.new_file";
		};
		['Toolbar'] = {
			view = true;
			frame = true;
			icon = 'res/save.bmp';
			action ="action.open_file";
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


local functionKeys = {
	action = true;
	
}

init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	local db = dat --sysTools.deepcopy(dat)
	for k,keyDat in pairs(db) do 
		keywordDat[k] = {}
		setmetatable(keywordDat[k],
			{
				__index = function(tab,key)
					local cur = keyDat[key]
					if not cur then return end 
					if type(cur) == 'table' and cur.type == 'function'  and cur.value == 'string'  then 					
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
					elseif functionKeys[key] then
						
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


--]===]
