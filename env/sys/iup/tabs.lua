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
--]]
--[[
	how to use :
		local tabClass = require ''.Class:new(attributesTab)
		local iupTab = tabClass:get_control()

		dlg = iup.dialog{
			iup.vbox{
				iupTab;
			};

		}

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
local tonumber = tonumber
local tostring = tostring
local error = error
local type = type
local pairs = pairs
local ipairs = ipairs
local print = print
local table = table

_ENV = _M

Class = {}
iupClass_:met(Class)


function Class:new(args)
	local t = self:met()
	t:init_control(iup.tabs(args))
	t:init(args)
	return t
end

function Class:init(args)
	self:init_tab_pages()
	self:init_tab_pages_dat(args)
end

-----------------------------------------------------------------
--set&get tab page data

function Class:init_tab_pages()
	self.tabPages = {}
end

function Class:get_tab_pages()
	return self.tabPages
end

function Class:init_tab_pages_dat(args)
	args = args or {}
	local tabPages = self:get_tab_pages()
	local str;
	for k,v in ipairs(args) do 
		str =  tostring(v)
		if  type(v) == 'userdata' then 
			tabPages[#tabPages+1] = v
		else
			break
		end
	end
end


-----------------------------------------------------------------
--set&get attributes
--color = 'R G B' or '#RRGGBB' such as: '#ff0000'
function Class:set_bgcolor(color)
	local control = self:get_control()
	control.BGCOLOR = color
end

--type = 'TOP','BOTTOM','LEFT','RIGHT' --default = 'TOP'
function Class:set_tabtype(type)
	local control = self:get_control()
	control.TABTYPE = type
end


--status = 'YES' or 'NO'
function Class:set_showclose(status)
	local control = self:get_control()
	control.SHOWCLOSE = status or 'YES'
end

-- size = 'width x height'
function Class:set_rastersize(size)
	local control = self:get_control()
	control.RASTERSIZE = size
end

--var:pos or hwnd ,str :title name
function Class:set_tabtitle(var,str)
	local control = self:get_control()
	local pos = type(var) == 'number' and var or self:get_pos(var)
	control["TABTITLE" .. pos] = str
end

function Class:set_tabimage(var,image)
	local control = self:get_control()
	local pos = type(var) == 'number' and var or self:get_pos(var)
	control["TABIMAGE" .. pos] = image
end

--status = 'NO' or 'YES' ,var type maybe :number or userdata . 
function Class:set_tabvisible(var,status)
	local control = self:get_control()
	local pos = type(var) == 'number' and var or self:get_pos(var)
	control['TABVISIBLE' .. pos] = status
end

--获得tab页的个数
function Class:get_count()
	local control = self:get_control()
	return control.COUNT
end

--根据页所在的位置切换当前页
function Class:set_by_pos( pos )
	local control = self:get_control()
	local num = self:get_count()
	if pos > num then  return end
	control.VALUEPOS= pos - 1
end

--根据页的标题名切换当前页。注意：这需要保证页的名称是唯一的
function Class:set_by_tabtitle( name )
	local control = self:get_control()
	local num = self:get_count()
	for i = 1,num do
		local title = control["TABTITLE" .. (i-1)]
		if title == name then 
			control.VALUEPOS = i-1
			return true 
		end
	end
end

--根据页的iup创建的对象切换当前页。
function Class:set_by_hwnd( hwnd )
	local control = self:get_control()
	control.VALUE   = hwnd
end

--设置当前页。
function Class:set_cur_page(key)
	if type(key) == 'string' then 
		return self:set_by_tabtitle( key )
	elseif type(key) == 'userdata' then 
		return self:set_by_hwnd( key )
	elseif type(key) == 'number' then 
		return self:set_by_pos( key )
	end
end

--追加tab进入tabs
function Class:append_tab(tab)
	local control = self:get_control()
	if not control then return end
	
	iup.Append(control,tab)
	iup.Map(tab)
	iup.Refresh(control)
	
	local tabPages = self:get_tab_pages()
	tabPages[#tabPages+1] = tab
end

--追加插件数据进入tabs
--tab = {hwnd,keyword,current,hide,...}
-- function Class:append_pluginLeftDlg(tab)
	-- local control = self:get_control()
	-- if not control then return end 
	-- local hwnd = tab.hwnd
	-- iup.Append(control,hwnd)
	-- iup.Map(hwnd)
	-- iup.Refresh(hwnd)
	-- local tabPages = self:get_tab_pages()
	-- tabPages[#tabPages+1] = hwnd
-- end

function Class:get_pos(tab)
	local tabPages = self:get_tab_pages()
	for k,v in ipairs(tabPages) do 
		if v == tab then 
			return k - 1
		end
	end

end

function Class:get_delete_pos(tab)
	return self:get_pos(tab) + 1
end

function Class:delete_tab(child)
	local pos = self:get_delete_pos(child)
	if pos then 
		local tabPages = self:get_tab_pages()
		table.remove(tabPages,pos)
		iup.Detach(child)
	end
end

function Class:add_tab(child)
	self:append_tab(child)
end

function Class:insert_first(tab)
	local control = self:get_control()
	if not control then return end 
	local tabPages = self:get_tab_pages()
	iup.Insert(control,tabPages[1], tab)
	iup.Map(tab)
	iup.Refresh(tab)
	table.insert(tabPages,1,tab)
end


function Class:change_tabtitle(child,new)
	local pos = self:get_pos(child)
	if pos then 
		self:set_tabtitle(pos,new)
	end
end

function Class:init_tab_attribute(pos,attrTab)
	self:set_tabtitle(pos,attrTab.tabtitle)
	self:set_tabimage(pos,attrTab.tabimage)
	self:set_tabvisible(pos,attrTab.tabvisible)
end

function Class:update_tabs()
	local tabPages = self:get_tab_pages()
	local pos,t;
	for k,v in ipairs(tabPages) do 
		pos = k-1;
		t = tabPages[v] or {}
		self:init_tab_attribute()
	end
end
