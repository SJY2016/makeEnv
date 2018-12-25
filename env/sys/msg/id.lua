local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local msg = require 'sys.msg'
local ID = ID

_ENV = _M

local IdTime = ID;
local IdCmd = ID;
local RegTime = false;
local RegCommand = false;
local RegFrmCommand = false;

local IdsTimer = {};--{[id]=function} --时间ID
local IdsCmd = {};--{[id]=function} --视图ID
local IdsFrmCmd = {};--{[id]=function} --非视图ID

function get_timer_id()
	IdTime=IdTime+1;
	return IdTime;
end

function get_command_id()
	IdCmd=IdCmd+1;
	return IdCmd;
end

function timers()
	return IdsTimer;
end

function commands()
	return IdsCmd;
end

function frm_commands()
	return IdsFrmCmd;
end

function set_timer(fun)
	local id = get_timer_id()
	timers()[id] = fun;
	if not RegTime then 
		RegTime = true
		msg.add('on_timer',function(scene,id)
			local fun = timers()[id]
			if  type(fun) == 'function' then 
				return fun(scene)
			end
		end)
	end
end

function set_command(fun)
	local id = get_command_id()
	commands()[id] = fun;
	if not RegCommand then 
		RegCommand = true
		msg.add('on_command',function()
			local fun = commands()[id]
			if  type(fun) == 'function' then 
				return fun(scene)
			end
		end)
	end
end

function set_frm_command(fun)
	local id = get_command_id()
	frm_commands()[id] =fun;
	if not RegFrmCommand then 
		RegFrmCommand = true
		msg.add('frm_on_command',function(id)
			local fun = frm_commands()[id]
			if  type(fun) == 'function' then 
				return fun()
			end
		end)
	end
end

