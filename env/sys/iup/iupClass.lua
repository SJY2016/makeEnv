
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local getmetatable = getmetatable
local setmetatable = setmetatable
local assert = assert
local ipairs = ipairs
local type = type
local print = print
local iup = require 'iuplua'
local table = table

_ENV = _M

Class = {}

function Class:met(t)
	t = t or {}
	if getmetatable(t) then return t end 
	setmetatable(t,self);
	self.__index = self;
	t:init_reg_cbfs() -- regCbfs = {} : reg cbf function table
	t:init_iup_cbfs() --iupCbfs= {}  iup cbf function table
	return t;
end

function Class:new(t)
	t = t or {};
	return self:met(t);
end

function Class:set()
end

---------------------------------------------------------
--警告函数
function Class:warning(iupElement)
	local iupElement = iupElement or self:get_control()
	return assert(iupElement,'Please create object firstly by "Class:new()" !')
end

function Class:map_warning()
	return assert(self.map,'no map !')
end
---------------------------------------------------------
--
function Class:init_control(ctl)
	self.iupElement = ctl
end

function Class:get_control()
	if not self:warning(self.iupElement) then return end
	return self.iupElement
end

function Class:init_reg_cbfs()
	self.regCbfs = {}
end

function Class:init_iup_cbfs()
	self.iupCbfs = {}
end

function Class:get_iup_cbfs(key)
	return key and self.iupCbfs[key] or self.iupCbfs
end

function Class:get_reg_cbfs(key)
	return key and self.regCbfs[key] or self.regCbfs
end

--arg = {key,cbf}
function Class:add_iup_cbf(arg)
	self.iupCbfs[arg.name or arg.key] = {cbf = arg.cbf,key = arg.key}
	self.regCbfs[arg.name or arg.key] = {}
end


function Class:map_cb(key)
	local temp = self
	local element = self:get_control()
	if not self:warning(element) then return end 
	function element:map_cb()
		temp.map = true
		return temp:run_callbacks(key,self)
	end
end

---------------------------------------------------------
--注册 回调函数
function Class:reg_callback(name,cb)
	if not cb then return end 
	local t =self:get_iup_cbfs(name)
	if t and not t.status and type(t.cbf) == 'function' then 
		t.cbf(t.key)
		t.status = true
	end
	local regCbfs =  self:get_reg_cbfs()
	regCbfs[name] = regCbfs[name] or {}
	if not regCbfs[name][cb] then 
		regCbfs[name][#regCbfs[name]+1] = cb
		regCbfs[name][cb] = true
	end
end

function Class:reg_callbacks(name,cbs)
	if not self.cbs then return end 
	for k,cb in ipairs(cbs) do 
		self:reg_callback(name,cb)
	end
end

function Class:get_cb_pos(name,cb)
	local regCbfs = self:get_reg_cbfs()
	local t = regCbfs[name] or {} 
	for i=1,#t do 
		if t[i] == cb then 
			return i
		end
	end
end

function Class:delete_callback(name,cb)
	local regCbfs = self:get_reg_cbfs()
	local pos = self:get_cb_pos(name,cb)
	if pos then 
		table.remove(regCbfs[name],pos)
		regCbfs[name][cb] = nil
	end
end

--通用运行回调函数,该函数仅处理需要判断达到条件返回结果的样式，不适合处理无论是否达成条件都需要循环执行的回调样式。
function Class:run_callbacks(key,...)
	local t = self:get_reg_cbfs(key)
	if #t ==0 then return end 
	for k,v in ipairs(t) do 
		if type(v) == 'function' then 
			local val = v( ... )
			if val then return val end 
		end
	end
end

function Class:run_callbacksAll(key,...)
	local t = self:get_reg_cbfs(key)
	if #t ==0 then return end 
	for k,v in ipairs(t) do 
		if type(v) == 'function' then 
			v( ... )
		end
	end
end
---------------------------------------------------------