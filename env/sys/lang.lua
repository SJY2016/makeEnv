--[[
/*
*Author:Sun JinYang
*Begin:2017年12月13日
*Description:
*	此文件用来处理语言版本相关功能。
*Record:（Time Content）
*		2018年4月2日 将语言改为类的模式
*/
--]]
--[[
数据结构：
	语言版本整体数据表结构：
		[ver]:key值为string类型，语言版本的缩写形式（文件夹名称）。对应值为table结构。table中包含的属性内容如下：（当相关文件不存在时，属性为nil）
			confPath:值为string类型，lang.conf文件的全路径。
			confDat:值为table类型，接收lang.conf文件中存储的数据（仅在使用时才会赋值,每个id对应的值均在初始化时转化为asc值）。
			readmePath:值为string类型，readme.lua文件的全路径
			readmeDat:值为table类型，readme.lua文件存放的数据
			actionPath:值为string类型，action.lua文件的全路径
			actionRequireMod：值为table类型，require文件。
Lang/ 文件说明：
	readme.lua文件中定义当前语言信息。目前所支持的属性有：
		name:值为string类型，当前语言包的名称。
		transcoding:值为boolean类型，当值为true时，语言包中的语言环境配置文件在读写时需要转换编码。（系统识别ASC2编码，其他编码格式的文本需要转换成ASC2码）。
	lang.conf文件中存放的是当前语言包中包含的数据。
config/Lang/ 文件说明：
	user_lang_ver.conf 
		记录用户使用的语言版本。
	en/
	zh/
	...
	语言版本文件夹存放插件安装后插件内部使用的语言环境。
	特殊字符：
		' ':带空格的组合字符串，会根据空格前后的字符串分别查找并最后组合成新的字符串。
		"&"：被&符号分割的id，识别时会被替换成空格处理。与空格不同的是，在en环境下不会分段查找，如果没有相对应的值则自动截取字符前的内容作为显示内容。
		"&&"：被&&符号分割的id，识别时会被替换成空格处理。与&不同，它是截取字符后的内容作为显示内容。[MalA
接口函数:
	Class:new(groupName)
		创建语言对象。
		groupName:参数值为string类型，设置分组名称。（组名需使用文件路径的方式，保证组名的唯一性。可以用来对使用的key分组，也可以用来在使用结束后清除不需要记录的内容。）
			注意：组的名字设置需使用/分隔文件所在路径。例如 "app/greenmark/dlgs/dlg_assigning"
	Class:change(langVer)
		切换语言版本.同时更新相应的语言环境。
		langVer:参数值为string类型。语言版本,例如:zh,en ... 
	Class:get_ver()
		获得当前语言版本。
		return：返回值为string类型。
	Class:get_list()
		获得版本列表；
		return:返回值为table类型。由字符串组成的数组结构的表。如：{'en','zh'}
	Class:get_ver_name_list()
		获得版本列表及对应名字的表
		return:返回值为table类型。由表组成的数组结构的表。子表的结构如下：
			ver:值为string类型，版本名。
			name:值为string类型，版本对应的名称。
	Class:get_name(ver)
		获得版本对应的名称。比如zh版本对应的名称为"中文简体"。
		ver:值为string类型,版本名称，如果参数不存在则使用当前版本。
		return:返回值为string类型。
	Class:get_id_name(id,ver)
		获得与id对应的相关版本的值。
		id：值为string类型，语言索引id值。
		ver:值为string类型，语言版本值。没有则使用当前版本。
		return:返回值为string类型，如果找到对应的版本值，则返回该值，如果没有找到则原样返回。如果存在特殊字符，则参考特殊字符使用方法。
	Class:reg_update(fun)
		注册更新函数，当切换语言版本时，主动调用更新函数。
		使用场景：
			非模态对话框在弹出后，切换语言时更新对话框显示的语言。
			菜单、工具条等界面语言的更新。
		fun：参数值为function类型。更新函数
	Class:update()
		主动更新函数。调用更新命令。
	Class:close()
		语言关闭函数。在已知的程序主动关闭时，可以调用此函数关闭语言当前组的语言调用。
		关闭组,注意如果组名是插件名比如:app/greenmark/则认为是卸载greenmark 这个app那么会自动关闭所有包含app/greenmark/这样名称的组。
使用方法:
	local lang = Class:new('GroupName')
	lang:change('zh') --切换语言版本
	lang:close() --
	...
注意：
	语言id的查找方式：groupName中包含app的优先查找config文件夹下“appName”/lang/，如果存在lang文件夹则查找其中readme.lua文件读取该app中语言设置的相关信息。
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sys_disk_ = require 'sys.disk'
local lfs = require 'lfs'
local luaext_ = require 'luaext'

local ipairs = ipairs
local pairs = pairs
local type = type
local getmetatable = getmetatable
local setmetatable = setmetatable
local print = print
local assert = assert
local table = table
local string = string

_ENV = _M

--------------------------------------------------------------
--define var
--Ver : version
local dirLang = 'lang/'
local dirUser = 'config/'
local dirUserLang = dirUser .. 'lang/'

local filenameIdConf = 'id.conf'
local fileIdConf = dirLang .. filenameIdConf
local filenameReadme = 'readme.lua'
local filenameLangConf  = 'lang.conf'
local filenameAction = 'action.lua'
local filenameLangVerConf = 'user_lang_ver.conf'
local fileUserLangVer = dirUserLang .. filenameLangVerConf
local defaultLangVer = 'en'

local get_user_ver;
local change_user_ver;

local get_ids;
local update_ver_dat;
local get_ver_dat;
local update_readme_dat;
local update_conf_dat;

local get_ver_list;
local get_ver_name;
local get_ver_env;
local get_ids_name;
local get_id_name;

local init_group_dat;
local add_group_name;
local add_group_id;
local get_group_ids;
local add_group_update;


--------------------------------------------------------------
--对外接口
local Lang = {}
Class = Lang

function Lang:new(groupName)
	assert(type(groupName) == 'string')
	local t = {}
	setmetatable(t,self);
	self.__index = self;
	t.groupName= groupName
	add_group_name(groupName)
	return t
end


function Lang:change(langVer)
	change_user_ver(langVer)
	self:update()
end

function Lang:get_ver()
	return get_user_ver()
end

function Lang:get_list()
	return get_ver_list()
end

function Lang:get_ver_name_list()
	local dat = self:get_list()
	local t = {}
	for k, v in ipairs(dat) do 
		t[k] = {ver = v,name = self:get_name(v)}
	end
	return t
end

function Lang:get_name(ver)
	return get_ver_name(ver)
end

function Lang:get_id_name(id,ver)
	add_group_id(self.groupName,id)
	return get_id_name(id,ver)
end

function Lang:reg_update(fun)
	add_group_update(self.groupName,fun)
end

function Lang:update()
	run_update()
end

function Lang:close(appClose)
	delete_group(self.groupName,appClose)
end

--------------------------------------------------------------
--内部接口
local load_file = sys_disk_.file_read
local save_file = sys_disk_.file_save

local function init_coding()
	local function gets(fun,t)
		local newT= {}
		for k,v in pairs(t) do 
			newT[k] = fun(v);
		end
		return newT
	end

	local cmds = {}
	cmds['utf-8'] = {
		get = luaext_.u82a,
		set =luaext_.a2u8,
		gets = function(t) 
			return gets(luaext_.u82a,t) 
		end,
		sets = function(t) 
			return gets(luaext_.a2u8,t) 
		end
	}
	return function(str,funName,...)
		return cmds[str] and cmds[str][funName] and cmds[str][funName](...)
	end
end

local turn_coding = init_coding()

local init_user_ver = function()
	local file  = fileUserLangVer
	local userVer;
	return function()
		if not userVer then
			local t = load_file(file)
			userVer = t and t.currentLangver or defaultLangVer
		end
		return userVer
	end,
	function(ver)
		userVer = ver
		lfs.mkdir(dirUserLang)
		save_file(file,{currentLangver = ver})
	end
end

get_user_ver,change_user_ver = init_user_ver()

local init_ids = function()
	local file = fileIdConf
	local ids;
	return function()
		if not ids then 
			ids = load_file(file)
			assert(type(ids) == 'table')
		end
		return ids
	end
end

get_ids = init_ids()


local init_ver_dat = function()
	local dir = string.sub(dirLang,1,-2)
	local userDir = dirUserLang 
	lfs.mkdir(dirUserLang)
	local dat;
	return function()
		dat = {}
		for entry in lfs.dir(dir) do 
			if entry ~= '.' and entry ~= '..' then 
				local path = dir .. '/' .. entry
				local attr = lfs.attributes(path)
				assert(type(attr)=="table") --如果获取不到属性表则报错
				if(attr.mode == "directory") then
					local file = path .. '/' .. filenameLangConf
					local attrLang = lfs.attributes(file)
					if attrLang then 
						dat[entry] = {}
						local t = dat[entry]
						t.confPath = file
						if lfs.attributes(path .. '/' .. filenameReadme) then 
							t.readmePath = path .. '/' .. filenameReadme
						end
						if lfs.attributes(path .. '/' .. filenameAction) then 
							t.actionPath = path .. '/' .. filenameAction
						end
						if lfs.attributes(userDir .. entry .. '.conf') then 
							t.userConfPath = userDir .. entry .. '.conf'
						end
					end
				end
			end
		end
	end,function()
		if not dat then update_ver_dat() end
		return dat
	end
end

update_ver_dat,get_ver_dat = init_ver_dat()

update_readme_dat = function(ver,dat)
	local dat = dat or get_ver_dat()
	local ver =ver or  get_user_ver()
	local t = dat[ver]
	assert(type(t) == 'table')
	if  not t.readmePath then return end 
	if not t.readmeDat then 
		t.readmeDat = load_file(t.readmePath)
		assert(type(t.readmeDat) == 'table')
		if t.readmeDat.name then 
			if t.readmeDat.transcoding and t.readmeDat.coding then 
				t.readmeDat.name = turn_coding(t.readmeDat.coding,'get',t.readmeDat.name) or t.readmeDat.name
			end
		end
	end
end

update_conf_dat = function(ver,dat)
	local dat = dat or get_ver_dat()
	local ver =ver or  get_user_ver()
	local t = dat[ver]
	assert(type(t) == 'table')
	assert(t.confPath)
	if not t.userConfDat and  t.userConfPath then 
		t.userConfDat = load_file(t.userConfPath)
		assert(type(t.userConfDat) == 'table')
		if t.readmePath then 
			if  not t.readmeDat then update_readme_dat(ver,dat) end
			if t.readmeDat.transcoding and t.readmeDat.coding then 
				t.userConfDat = turn_coding(t.readmeDat.coding,'gets',t.userConfDat)
			end
		end
	end
	if not t.confDat then 
		t.confDat = load_file(t.confPath)
		assert(type(t.confDat) == 'table')
		if t.readmePath then 
			if  not t.readmeDat then update_readme_dat(ver,dat) end
			if t.readmeDat.transcoding and t.readmeDat.coding then 
				t.confDat = turn_coding(t.readmeDat.coding,'gets',t.confDat)
			end
		end
	end
end

get_ver_list = function ()
	local dat = get_ver_dat()
	local list = {}
	for k,v in pairs(dat) do 
		list[#list+1] = k
	end
	table.sort(list)
	return list
end

get_ver_name = function (ver)
	local ver =ver or  get_user_ver()
	local dat = get_ver_dat()
	local t = dat[ver]
	if not t then  return end 
	if  not t.readmeDat then update_readme_dat(ver,dat) end
	return t.readmeDat and t.readmeDat.name or ver
end

get_ver_env = function(ver)
	local ver =ver or  get_user_ver()
	local dat = get_ver_dat()
	local t = dat[ver]
	if not t then  return end 
	if  not t.confDat then update_conf_dat(ver,dat) end
	return t.confDat
end

get_id_name = function(id,ver)
	if not id then return end 
	local env = get_ver_env(ver)
	if not env then return end
	local newId = string.gsub(id,'&+',' ')
	local str = env[newId] or env[string.lower(newId)]
	if str then return str end

	local ver =ver or  get_user_ver()
	local saveSpace = ''
	if ver == 'en' then 
		saveSpace = ' '
	end
	local name;
	if string.find(id,'&&') and ver == 'en' then 
		return string.match(id,'&([^&]+)')
	elseif string.find(id,'&') and ver == 'en' then 
		return string.match(id,'[^&]+')
	end

	if string.find(newId,'%s') then 
		string.gsub(newId,'%S+',function(str)
			local envStr = env[str] or env[string.lower(str)] or str
			name = name and (name .. saveSpace ..  envStr ) or envStr 
		end
		)
	end
	return  name or newId
end

--ids = {'','',}
--return {id1 = '',id2 = ''}
get_ids_name = function(ids,ver)
	local env = get_ver_env(ver)
	if not env then return end
	assert(type(ids) == 'table')
	local t = {}
	for k,v in ipairs(ids) do 
		t[v] = env[v] or v
	end
	return t
end

local init_groups = function()
	local groups = {}
	return function()
		groups = {}
	end,
	function(groupName)
		groups[groupName] = groups[groupName] or {ids ={},updateFuns = {}}
	end,
	function(groupName,...)
		local args = {...}
		groups[groupName] = groups[groupName] or {ids ={},updateFuns = {}}
		for i = 1,#args do 
			groups[groupName].ids[args[i]] = true
		end
	end,
	function(groupName)
		return groups[groupName]
	end,
	function (groupName,...)
		local args = {...}
		for i = 1,#args do 
			if type(args[i]) == 'function' then 
				groups[groupName].updateFuns[args[i]] = true
			end
		end
	end,
	function()
		for groupName,groupT in pairs(groups) do 
			if groupT.updateFuns then 
				for fun in pairs(groupT.updateFuns) do 
					fun()
				end
			end
		end
	end,
	function(groupName,appClose)
		groups[groupName] = nil
		if appClose then 
			for name,v in pairs(groups) do 
				local curName =  string.match(name,'([^/%s]+)') 
				if curName == groupName then 
					groups[curName] = nil
				end
			end
		end
	end
end

init_group_dat,
add_group_name,
add_group_id,
get_group_ids,
add_group_update,
run_update,
delete_group = init_groups()
