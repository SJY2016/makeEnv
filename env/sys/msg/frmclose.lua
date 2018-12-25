local _M = {}
_G[...] = _M
package.loaded[...] = _M

local msg = require 'sys.msg'

local pairs = pairs
local type = type

_ENV = _M

function add(f)
	if type(f)~='function' then return end
	msg.add('frmclose',f)
end

function del(f)
	if type(f)~='function' then return end
	msg.delete('frmclose',f)
end


