--[[
/*
*Author:Sun JinYang
*Begin:2018年03月19日
*Description:
*	此文件用来控制并显示APCAD左侧工作区。
*Record:（Time Content）
*/
--]]
--[[
数据结构:
接口函数：
使用示例：
--]]

-- local FRMCLOSE = apframe.get_msg_frmclose()

local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local dlgClass_ = require 'sys.iup.dlg'
local tabsClass_ = require 'sys.iup.tabs'
local classKeyword = require 'sys.keyword'.Class

local msgFrmclose = require 'sys.msg.frmclose'

local iup = iup
local frm_hwnd = frm_hwnd
local add_dlgtree = add_dlgtree
local dlgtree_show = dlgtree_show
local frm = frm
local print = print
local ipairs = ipairs
local type = type
local string = string
local pairs = pairs
local setmetatable = setmetatable

_ENV = _M

local objKeyword = classKeyword:new()

local dlgCloseStatus;
local isShow;
local noShow;

local tabs = tabsClass_.Class:new{
	TABTYPE = 'BOTTOM';
	showclose = "NO";
	rastersize = '300x';
}
local dlg = dlgClass_.Class:new{
	 tabs:get_control()
}

local iupDlg = dlg:get_control()
iupDlg.BORDER="NO"
iupDlg.shrink = 'yes'
iupDlg.MAXBOX="NO"
iupDlg.MINBOX="NO"
iupDlg.MENUBOX="NO"
iupDlg.CONTROL = "YES"
iupDlg.rastersize = '300x'
iupDlg.expand = 'yes'

iup.SetAttribute(iupDlg,"NATIVEPARENT",frm_hwnd)

dlg:reg_callback('map_cb',function()
	dlgCloseStatus = nil
	add_dlgtree(frm,iupDlg.HWND)
end)

dlg:reg_callback('destroy_cb',function()
	dlgCloseStatus = true;
end)

function init()
	dlg:map()
	msgFrmclose.add(function()  iup.Destroy(iupDlg) end)
end

function get_dlgCloseStatus()
	return dlgCloseStatus
end

--arg = {hwnd = ,}
function add(arg)
	if not arg or not arg.hwnd then return end 
	local hwnd = arg.hwnd
	tabs:add_tab(hwnd)
end

function delete(hwnd)
	if not hwnd then return end
	tabs:delete_tab(hwnd)
end


function show()
	isShow = true
	if tabs:get_count() == 0 then noShow = true return end 
	dlg:show()
end

function tab_status(child,status,active)
	tabs:set_tabvisible(child,status)
	if status == 'yes' and active then 
		tabs:set_cur_page(child)
	end
end

--arg = {hwnd = ,}
function append(arg)
	if not arg or not arg.hwnd then return end 
	local hwnd = arg.hwnd
	if arg.first then 
		tabs:insert_first(hwnd)
	else
		tabs:add_tab(hwnd)
	end
	if arg.current then 
		tabs:set_cur_page(arg.hwnd)
	end 
	if arg.hide then 
		tabs:set_tabvisible(arg.hwnd,'NO')
	end
	if isShow and noShow then 
		dlg:show()
	end 
end


function display_state(state)
	dlgtree_show(frm,state)
end

function update(t)
	--[[
	if t then 
		for k,v in ipairs(t) do 
			if type(v) == 'table' and v.hwnd then 
				v.hwnd.margin = '0x0';
				append(v)
			end
		end
	end
	--]]
	-- dlg:show()
end


function set_cur_page(keyIndex)
	tabs:set_cur_page(keyIndex)
end

function update_name(child,name)
	tabs:change_tabtitle(child,name)
	return true
end

function frmclose()
end

function get_dlgHeight()
	return string.match(iupDlg.size,'.+x([^x]+)')
end
-----------------------------------------------------------------------------------------
function set_width(width)
	iupDlg.size = width .. 'x'
	if isShow then 
		iup.Refresh(iupDlg)
	end
end

function set_rasterwidth(width)
	iupDlg.rastersize = width .. 'x'
	if isShow then 
		iup.Refresh(iupDlg)
	end
end

local cmdAttributes = {
	width = set_width;
	rasterwidth = set_rasterwidth;
}

function init_attributes(dat)
	for key,val in pairs(dat) do 
		if cmdAttributes[key]  then 
			cmdAttributes[key](val)
		end
	end
end

local function init_pluginTabs()
	local tabs = {}
	
	--tabs = {keyword = {},...}
	
	return function(dat,temp)
		local keyword,tabtitle = dat.keyword,dat.tabtitle
		if tabs[keyword] or type(temp) ~= 'table' then return end 
		if type(temp.onLoad) == 'function' then 
			temp.onLoad()
		end
		local hwnd = type(temp.hwnd) == 'function' and temp.hwnd() or (type(temp.hwnd) == 'userdata' and temp.hwnd );
		if not hwnd then return end 
		hwnd.tabtitle = tabtitle or hwnd.tabtitle or ''
		-- local lang = langClass_:new(keyword)
		append{
			hwnd = hwnd;
			keyword =keyword;
			current = temp.current;
			hide = temp.hide;
		}
		-- lang:reg_update(function()
			-- sysLeftDlg.update_name(temp.hwnd,lang:get_id_name(temp.tabtitle))
		-- end)
		tabs[keyword] = {lang = lang}
		setmetatable(tabs[keyword],{__index = temp})
		if type(temp.onInit) == 'function' then 
			temp.onInit()
		end
	end,function(plugin)
		for k,v in pairs(tabs) do 
			if v.plugin == plugin then 
				local hwnd = type(v.hwnd) == 'function' and v.hwnd() or (type(v.hwnd) == 'userdata' and v.hwnd );
				if hwnd then 
					delete(hwnd)
					-- v.lang:close()
					tabs[k] = nil;
					if type(v.onUnload) == 'function' then 
						v.onUnload()
					end
				end
			end
		end
	end
end

local add_page,remove_page = init_pluginTabs()

function init_pages(dat)
	for key,val in ipairs(dat) do 
		if type(val) == 'table' and val.keyword then 
			add_page(val,objKeyword:get_keywordDat(val.keyword) )
		end
	end
end

