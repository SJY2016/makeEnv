local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local rpath,path = require 'sys.tools'.get_path(modname)

local setmetatable = setmetatable
local ipairs = ipairs
local type = type
local print = print
local table = table
local trace_out = trace_out

_ENV = _M


local sysCbfs = {}


function init()
	sysCbfs = {}
end


--add msg
function add(cbfType,cbf)
	sysCbfs[cbfType] = sysCbfs[cbfType] or {}
	if not sysCbfs[cbfType][cbf] then 
		sysCbfs[cbfType][cbf]  = true
		sysCbfs[cbfType][#sysCbfs[cbfType]+1] = cbf
	end
end

--reset msg
function reset(cbfType,oldCbf,newCbf)
	sysCbfs[cbfType] = sysCbfs[cbfType] or {}
	local funs = sysCbfs[cbfType] 
	if funs[oldCbf] then 
		for k,v in ipairs(funs) do 
			if v == oldCbf then 
				funs[k] = newCbf
				funs[oldCbf] = nil
				funs[newCbf] = true
				return 
			end
		end
	end
	funs[#funs+1] = newCbf
	funs[newCbf] = true
end

--run msg
function run(cbfType,...)
	local funs = sysCbfs[cbfType]
	if funs then 
		for k,fun in ipairs(funs) do 
			if fun(...) then return end 
		end
	end
end

--stop msg
function stop(cbfType)
	
end

--delete msg
function delete(cbfType,fun)
	local funs = sysCbfs[cbfType] or {}
	if funs[fun] then 
		for k,v in ipairs(funs) do 
			if v == fun then 
				table.remove(funs,k)
				funs[fun] = nil
				return 
			end
		end
	end
end

--get reg funs
function get(cbfType)
	return sysCbfs[cbfType]
end

----------------------------------------------------------------------