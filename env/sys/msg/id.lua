local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local msg = require 'sys.msg'
local sysKeyword = require 'sys.keyword'

local ID = ID

local type = type
local print = print
local pairs = pairs

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

local function init_ids()
	local ids = {}
	return function(id,fun)
	end,function(id)
	end
end

local Ids = {}
function map(id,keyword)
	Ids[id] = keyword
end

local function run(id,sc)
	local keyword = Ids[id]
	if not keyword then return end 
	local dat = sysKeyword.get_keywordDat(keyword)
	if type(dat) ~= 'table' then return end 
	if sc and dat.view then 
		return dat.action(sc)
	elseif not sc and dat.frame then 
		return dat.action()
	end
	
end

msg.add('on_command',run)
msg.add('frm_on_command',run)


-------------------------------------------------------------------------------------------------------

