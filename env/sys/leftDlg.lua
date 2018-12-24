
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = require 'sys.tools'
local rpath,path = sysTools.get_path(modname)
local dlgClass_ = require (rpath .. 'iup.dlg')
local tabsClass_ =require (rpath .. 'iup.tabs')

local frameTree = require (rpath .. 'tree.tree_frame')
local iup = require 'iuplua'
local frm_hwnd = frm_hwnd
local add_dlgtree = add_dlgtree
local dlgtree_show = dlgtree_show
local frm = frm
local print = print
local ipairs = ipairs
local type = type
local string = string
local FRMCLOSE = FRMCLOSE

_ENV = _M

local dlgCloseStatus;

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
iupDlg.size = '300x'
iupDlg.expand = 'yes'

iup.SetAttribute(iupDlg,"NATIVEPARENT",frm_hwnd)

dlg:reg_callback('map_cb',function()
	dlgCloseStatus = nil
	add_dlgtree(frm,iupDlg.HWND)
end)

dlg:reg_callback('destroy_cb',function()
	dlgCloseStatus = true;
end)



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
end


function display_state(state)
	dlgtree_show(frm,state)
end

local function init_pages()
	local pages = {}
	return function(tab)
		pages[#pages+1] = tab
	end,function()
		for k,tab in pairs(pages) do 
			append(tab)
		end
	end
end

reg_page,run_pages = init_pages()

----------------------------------------------------------------------------------

function load()
	dlg:map()
	show()
	display_state(true)
	append{hwnd = frameTree.get_frame(),tabtitle = 'Browser'}
	FRMCLOSE.add(function()  iup.Destroy(iupDlg) end)
end

----------------------------------------------------------------------------------




function init()
	frameTree.init_dat()
end

--run

