
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = TOOLS
local rpath,path = sysTools.get_path(modname)
local frameTree = require (rpath .. 'tree_frame')

_ENV = _M


----------------------------------------------------------------------------------

local hwnd;

function get_hwnd()
	hwnd  = frameTree.get_frame() 
	return hwnd
end
----------------------------------------------------------------------------------

function on_init()
	frameTree.init_dat()
end

function on_unload()

end

--run

