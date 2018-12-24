--[[
/*
*Author:Sun JinYang
*Begin:2018年03月02日
*Description:
*	操作iup dialog 
*Import Update Record:（Time Content）
*	2018/03/30 修改对话框中回调的方法改为新的reg_callback模式
*/
--]]
--[[
数据结构：
	
接口函数：
	Class:new(childs)
		创建对象
		childs：参数值为table类型，表内为iup.dialog需要的控件及dialog初始的属性值。
		return :返回值为table类型，table为创建出的对象。
	---------------------------------------------------------------------------------------
	--get
	Class:get_control()
		获得创建的iup对象。
		return:返回值为userdata(IUP)类型。
	Class:get_modal()
		获得当前对话框状态,MODAL属性值
		return 'YES'(弹出模式为popup，模态对话框 ) or 'NO'（弹出模式为show，非模态对话框。或者界面没显示。）
	Class:is_popup()
		判断是否为模态对话框（内部调用了get_modal）
		return true or nil。true:代表当前为模态对话框并且是弹出状态,nil 代表当前对话框隐藏或者非模态对话框
	Class:get_title()
		获得对话框的标题名称
		return:返回值为string类型。设置的标题名称。
	---------------------------------------------------------------------------------------
	--set
	Class:set_opacity(number)
		设置对话框的透明样式
		number:值为number类型，取值范围在0~255，255 为不透明。
	Class:set_title(title)
		设置对话框左上角显示的标题
		title:值为string类型，标题名

	---------------------------------------------------------------------------------------
	--show、hide
	Class:show()
		非模态显示对话框
	Class:popup()
		模态显示对话框
	Class:map()
		显示对话框前先map对象
	Class:hide()
		隐藏对话框
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = require 'sys.tools'
local rpath,path = sysTools.get_path(modname)
local iupClass_ = require (rpath .. 'iupClass').Class
local iup = require 'iuplua'
require 'iupluacontrols'
local enablewindow = enablewindow
local frm_hwnd = frm_hwnd
local print = print
local type = type
local ipairs = ipairs
local pairs = pairs
local string = string
local tonumber = tonumber

_ENV = _M

Class = {}
iupClass_:met(Class)

local popCount = 0

function Class:new(childs)
	local t = self:met()
	t:init_control(iup.dialog(childs))
	t:init()
	iup.SetAttribute(t.iupElement,"NATIVEPARENT",frm_hwnd)
	return t
end

function Class:init()
	self:add_iup_cbf{key = 'map_cb',cbf = function(key) self:map_cb(key) end}
	self:add_iup_cbf{key = 'show_cb',cbf = function(key) self:show_cb(key) end}
	self:add_iup_cbf{key = 'close_cb',cbf = function(key) self:close_cb(key) end}
	self:add_iup_cbf{key = 'destroy_cb',cbf = function(key) self:destroy_cb(key) end}
end
-----------------------------------------------------------------

--（只读）获得对话框的弹出模式,需要在对话框弹出后使用,第一次调用时show_cb还未赋值，所以不能再show_cb中使用该属性,'YES'代表popup弹出
--注意：调用hide后对话框关闭该状态就变了。
function Class:get_modal()
	local element = self:get_control()
	if not self:warning(element) then return end 
	return element.MODAL
end

function Class:is_popup()
	if self:get_modal() == 'YES' then
		return true
	end
end

--number:0~255,设置对话框的透明度
function Class:set_opacity(number)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.OPACITY  = number
end

function Class:set_title(title)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.TITLE = title
end
function Class:get_title()
	local element = self:get_control()
	if not self:warning(element) then return end 
	return element.TITLE
end
-----------------------------------------------------------------
--set callback

--[[
	state:number 
	possible value:
		IUP_HIDE (since 3.0)、
		IUP_SHOW、
		IUP_RESTORE (was minimized or maximized)、
		IUP_MINIMIZE、
		IUP_MAXIMIZE (since 3.0) (not received in Motif when activated from the maximize button)
--]]
function Class:show_cb(key)
	local temp = self
	local element = self:get_control()
	if not self:warning(element) then return end 
	function element:show_cb(state) 
		local t = temp:get_reg_cbfs(key)
		local close;
		for k,v in ipairs(t) do 
			if type(v) == 'function' then 
				local val = v(state)
				if val and val == iup.CLOSE then 
					close = true
				end
			end
		end
		if close then return iup.CLOSE end 
	end
end

function Class:map_cb(key)
	local temp = self
	local element = self:get_control()
	if not self:warning(element) then return end 
	function element:map_cb()
		return temp:run_callbacks(key,self)
	end
end

function Class:destroy_cb(key)
	local temp = self
	local element = self:get_control()
	if not self:warning(element) then return end 
	function element:destroy_cb()
		return temp:run_callbacks(key,self)
	end
end

function Class:close_cb(key)
	local temp = self
	local element = self:get_control()
	if not self:warning(element) then return end 
	function element:close_cb()
		local t = temp:get_reg_cbfs(key)
		local ignore;
		for k,v in ipairs(t) do 
			if type(v) == 'function' then 
				local val = v()
				if val and val == iup.IGNORE then
					ignore = true
				end
			end
		end
		if not temp:is_popup()  then
			iup.Destroy(element)
			return iup.IGNORE
		elseif ignore then 
			return iup.IGNORE
		end
	end
end

-----------------------------------------------------------------
-- show close hide ...
function Class:show()
	local element = self:get_control()
	if not self:warning(element) then return end 
	self:reg_callback('close_cb',function()   end)
	element:show()
end

-- show close hide ...
--...:x,y
function Class:showxy(...)
	local element = self:get_control()
	if not self:warning(element) then return end 
	self:reg_callback('close_cb',function()   end)
	element:showxy(...)
end

function Class:hide()
	local element = self:get_control()
	if not self:warning(element) then return end 
	local isPop = self:is_popup()
	element:hide()
	if not isPop  then 
		iup.Destroy(element)
	end
end

function Class:map()
	local element = self:get_control()
	if not self:warning(element) then return end 
	element:map()
end

function Class:popup()
	local element = self:get_control()
	if not self:warning(element) then return end 
	self:reg_callback('show_cb',function()
		enablewindow(frm_hwnd,false)
	end	
	)
	popCount = popCount + 1
	element:popup()
	iup.Destroy(element)
	popCount = popCount - 1
	if popCount == 0 then 
		enablewindow(frm_hwnd,true)
	end
end

function Class:child_popup()
	local element = self:get_control()
	if not self:warning(element) then return end 
	element:popup()
	iup.Destroy(element)
end
