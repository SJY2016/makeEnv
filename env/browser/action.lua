local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local trace_out = trace_out

_ENV = _M

function new_file()
	trace_out('new_file\n')
end

function open_file()
	trace_out('open_file\n')
end