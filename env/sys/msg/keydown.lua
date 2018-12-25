local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local msg = require 'sys.msg'

_ENV = _M

function add(fun)
	msg.add('on_keydown',fun)
end

function delete(fun)
	msg.delete('on_keydown',fun)
end

function reset(fun)
	msg.reset('on_keydown',fun)
end