
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local classDlg = require 'sys.iup.dlg'.Class
local classLang = require 'sys.lang'.Class
local iup = require 'sys.iup'
local type = type
local string = string

_ENV = _M

function pop(val)	

	local name;
	
	local objLang = classLang:new('sys/dlgs/dlg_add')
	local labWid,btnWid = '60x','80x';
	
	local labName = iup.label{title = objLang:get_id_name('Name'),rastersize = labWid,fontstyle = 'Bold'}
	local txtName = iup.text{expand = 'HORIZONTAL'}
	txtName.value = val or ''
	
	iup.normalizer{
		labName;
		txtName;
		normalize = 'VERTICAL';
	}
	
	local btnOk = iup.button{title = objLang:get_id_name('OK'),rastersize = btnWid}
	local btnCancel = iup.button{title = objLang:get_id_name('Cancel'),rastersize = btnWid}
	
	local child = {
		iup.vbox{
			iup.hbox{labName,txtName};
			iup.hbox{btnOk,btnCancel};
			alignment = 'ARIGHT';
			margin = '5x5';
		};
		rastersize = '300x';
	}
	local dlg = classDlg:new(child)
	
	function btnCancel:action()
		dlg:hide()
	end
	function btnOk:action()
		name = txtName.value
		if not name or not string.find(name,'%S') then 
			name = nil
			return iup.Message('Warning','The name may not be empty !')
		end
 		dlg:hide()
	end
	
	dlg:popup()
	objLang:close()
	return name
end