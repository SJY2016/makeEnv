--[[
/*
*Author:Sun JinYang
*Begin:
*Description:
	控制工作区页
*Import Update Record:（Time Content）
*/
--]]

local M = {}
local modname = ...
_G[modname] = M
package.loaded[modname] = M

local tools = require 'sys.tools'
local rpath,path = tools.get_path(modname)
local lowerRequire = tools.get_lowerRequire()

local dlgPages = lowerRequire (rpath .. 'page.dlg')
local sysSetting = require (rpath .. 'setting')

local print = print
local type = type
local assert = assert
local pairs = pairs

_ENV = M


-------------------------------------------------------------------------------------
-- 显示工作区
function display()
	dlgPages.display_state( true )
end

-- 取消显示
function undisplay()
	dlgPages.display_state( false )
end

init = dlgPages.init
update = function()
	dlgPages.show()
end 
-------------------------------------------------------------------------------------

--add(arg) arg = {hwnd = iupControl,current,hide} --hwnd：iup元素，current =true当前显示页面,hide = true 隐藏添加的页
add = dlgPages.append

--delete(hwnd)
delete = dlgPages.delete

--set_cur_page(keyIndex)
set_cur_page = dlgPages.set_cur_page

--update_name(hwnd,newstr)
update_name = dlgPages.update_name

function hide(hwnd)
	dlgPages.tab_status(hwnd,'no')
end

--tabtitle:标签名,active控制显示时是否激活当前页
function show(hwnd,active)
	dlgPages.tab_status(hwnd,'yes',active)
end

get_dlgCloseStatus = dlgPages.get_dlgCloseStatus


sysSetting.reg_cbf(
	'page',
	function(dat)
		assert(type(dat) == 'table')
		local attributes = {}
		local pages = {}
		for k,v in pairs(dat) do 
			if type(k) ~= 'number' then 
				attributes[k] = v
			else 
				pages[k] = v
			end
		end
		dlgPages.init_attributes(attributes)
		dlgPages.init_pages(pages)
	end
)
