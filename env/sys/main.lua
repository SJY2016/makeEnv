

------------------------------------------------------------------------------
require"sys.msg.on_sys_msg";
------------------------------------------------------------------------------
CODE  =  require 'sys.code'
TOOLS = require 'sys.tools'
IUP = require 'sys.iup'
DISK = require 'sys.disk'
ZIP = require 'sys.zip'

SETTING =  require 'sys.setting'
KEYWORD =  require 'sys.keyword'
LANG = require 'sys.lang'
PAGE = require 'sys.page'


------------------------------------------------------------------------------
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local setting = SETTING
local sysPage = PAGE
local sysKeyword = KEYWORD
local sysLang = LANG

_ENV = _M

function load()
	sysPage.init()
	setting.init()
	sysPage.update()
	-- browser.load()
	setting.update()
end


load();
























