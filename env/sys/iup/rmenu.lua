local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local require = require
local type = type
local setmetatable = setmetatable
local table = table
local next = next
local ipairs = ipairs
local print = print

_ENV = _M
---------------------------------------------------------------------------------------------------
--[[
	data结构示例：
		data = {
			{title = ,action = ,active = }; -- 一个item（菜单中的一项）。
			{	
				title = ,
				submenu = {  -- 次级菜单
					{title = ,action = ,active = }; -- 一个item（菜单中的一项）。
					{title = ,action = ,active = }; -- 一个item（菜单中的一项）。
				};
			};
			''; -- 分隔线,注意只要不是table结构就默认为是分割线
			{title = ,action = ,active = };
		}
	item 详解：
	item = {title,action,active,...} --这些关键的属性大部分符合iup规则，
		title 代表item标题，值通常为string类型,
		action 触发点击消息，值通常为function类型
		active 对应该菜单的状态,值的类型可以直接给出 string 类型的值，也可以是个function 类型该函数中必须有返回值且值的类型是string。
			可接受的string的值有'yes','no','hide'
--]]
---------------------------------------------------------------------------------------------------
local iup = require 'iuplua'

local function create_item(arg)
	if type(arg) ~= "table" then return end 
	return iup.item(arg)
end

function create(arg)
	if type(arg) ~= "table" then return end 
	return iup.menu(arg)
end

function create_submenu(arg)
	if type(arg) ~= "table" then return end 
	return iup.submenu(arg);
end

function separator()
	return iup.separator{sep_ = true}
end

function refresh_menu(menu)
	iup.Refresh(menu)
end
---------------------------------------------------------------------------------------------------

local Class = {
}

function new(t)
	local t = t or {}
	setmetatable(t,Class)
	Class.__index = Class;
	return t
end

local function table_is_empty(t)
	return next(t) == nil
end

function Class:get_rmenu()
	return self.rmenu
end

function Class:set_data(datas)
	self.data = datas
end

function Class:get_data()
	return self.data
end

function Class:add_item(menu,item,tree,id)
	if not menu or  not item then return end 
	local cur_item;
	if type(item) == 'table' then 
		local active;
		if type(item.active) == 'string' then 
			active = item.active
		elseif  type(item.active) == 'function' then 
			active = item.active(tree,id)
		end 
		if active and active == 'hide' then return end 
		cur_item = create_item{title = item.title,action = item.action,active = active,value = item.value}
	else
		cur_item = separator()
	end 	
	if type(menu) == 'table' then
		table.insert(menu,cur_item)
	elseif type(menu) == 'userdata' then
		iup.Append(menu,cur_item)
	end
end

function Class:add_submenu(menu,title,submenu,radio)
	local item = create_submenu{
		title = title;
		radio = radio;
		create(submenu);
	}
	table.insert(menu,item)
end

local function init_data(data,menu,tree,id)
	for k,v in ipairs(data) do 
		if v.submenu then 
			local submenu = {}
			if type(v.submenu) == 'table' then 
				init_data(v.submenu,submenu,tree,id)
			elseif type(v.submenu) == 'function' then 
				local t = v.submenu() or {}
				init_data(t,submenu,tree,id)
			end 
			Class:add_submenu(menu,v.title,submenu,radio)
		else 
			Class:add_item(menu,v,tree,id)
		end 
	end 
end

function Class:init(tree,id)
	if type(self.data) ~= 'table' or table_is_empty(self.data) then return end 
	local menu = {}
	init_data(self.data,menu,tree,id)
	self.rmenu = create(menu)
	return true
end

function Class:show(tree,id)
	if not self:init(tree,id) then return end 
	if not self.rmenu then return end 
	iup.Refresh(self.rmenu)
	self.rmenu:popup(iup.MOUSEPOS,iup.MOUSEPOS)
	iup.Destroy(self.rmenu)
end
