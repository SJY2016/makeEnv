

------------------------------------------------------------------------------
require"sys.msg.on_sys_msg";
require 'sys.global'

------------------------------------------------------------------------------
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local setting = SETTING
local sysPage = PAGE

_ENV = _M

function load()
	sysPage.init()
	setting.init()
	sysPage.update()
	-- browser.load()
	setting.update()
end


load();
























