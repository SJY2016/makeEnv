--[[
/*
*Author:Sun JinYang
*Begin:2018年05月17日
*Description:
*	tree 重构
*Record:（Time Content）
*/
--]]
--[[
数据结构：
	tree:
		map:值为boolean类型，当值为true时，该类包含的界面对象已经被map。
		gidList:值为table类型，存储表的集合，将表的地址做为key值索引。
		rmenu:值为table 或者 function 类型，设置tree 默认的右键菜单功能.此属性会自动放置在全局的attributes属性表中。
		lbtn:值为function 类型，设置tree 默认的单击鼠标左键的功能.
		dlbtn:值为function 类型，设置tree 默认的双击鼠标左键功能.
		attributes:值为table或者返回table的function类型，设置tree的整体属性和节点的属性。如下：(具体请看下面的attributes的key值列表)
			鼠标响应消息key：
				rmenu:设置tree右键菜单
				lbtn:设置鼠标左键点击响应的函数
				dlbtn:设置双击鼠标左键响应函数。
			节点样式相关key：
				color:
				image:
				...
			节点绑定数据key：
				userdata:
			特殊继承属性：
				noShare:值为boolean类型，如果值为true，则当前节点属性不允许继承。
				endShare:值为boolean类型，如果值为true，则子节点不在继续向上继承。
			表内首字母为！号的属性，代表该属性仅当前节点有效，不会被继承。
			注意：
				title和userdata属性天然不允许继承，仅当前节点有效。
				--文件节点天然不会继承文件夹特有的节点属性。
				function类型的返回表可以做到动态修改某项属性。
				节点中的属性会不断的向上查找，如果没有找到相关的属性，那么会使用全局设置的属性，比如rmenu、lbtn、dlbtn。
		data：值为table类型，设置tree数据(包含tree的整体样式，节点的样式，tree中内容的层级结构，节点操作行为等)。table 中包含的数据结构如下：
		root:值为table类型，记录传入data数据中根属性（非树中的根节点属性，而是相当于-1节点的属性（树的根节点id是0））。
	node:节点中包含的数据结构如下：
		attributeId:值为string类型（Gid）。对应当前节点的属性表
		rootAttributeId：值为string类型（Gid）。对应子节点的终级属性表。
接口函数：
data结构样例：跳转到尾部。
attributes:(可接受的值有)
	color:设置节点title颜色
	image：设置节点图片
	imageLeaf：设置全局默认文件节点图片
	imageBranch：设置全局默认文件夹节点图片，值是table结构：{expanded = ,collapsed = }
	imageBranchCollapsed:设置全局默认文件夹节点闭合时显示的图片。
	imageBranchExpanded:设置全局默认文件夹节点展开时显示的图片。
	userdata:设置节点绑定的用户数据
	rmenu:
	lbtn:
	dlbtn:
---------------------------------------------------------------------------------------------------------------------------
二〇一八年十二月十日 
treeStyleId :tree 总样式索引gid
gidList：gid对应的数据列表。
节点属性：
	NodeStyleIndexIds:节点样式gid索引列表。默认取第一个gid对应的表为值为当前样式。
	InheritableStyleIndexGids:可继承节点样式gid索引列表。默认取第一个gid对应的表为值为当前样式。
	UserdatIndexGids：节点绑定数据gid索引列表，默认取第一个gid对应的数据表为当前数据表。
	
---------------------------------------------------------------------------------------------------------------------------
二〇一八年十二月二十日 

新增节点样式属性：
	iconFileType = true;
	imageLeaf = 'res/default.bmp'; --系统默认文件节点图标
	rmenu = {file = 'sys/tree/tree_frame.lua',action = 'on_rbtn',};
	lbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_lbtn',};
	dlbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_dlbtn',};
	
样式数据示例：
return {
	attributes = { --如果是
		iconFileType = true;
		imageLeaf = 'res/default.bmp'; --系统默认文件节点图标
		rmenu = {file = 'sys/tree/tree_frame.lua',action = 'on_rbtn',};
		lbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_lbtn',};
		dlbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_dlbtn',};
	};
	{
		attributes = {title = 'Project'};
		{
			{
				attributes = {title = 'kya.bmp'};
			};
		};
	};
}
--]]

local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M


local sysTools = require 'sys.tools'
local rpath,path = sysTools.get_path(modname)
local iupClass_ = require (rpath .. 'iupClass').Class
local classRmenu_ =  require (rpath .. 'rmenu')
local luaext_ = require 'luaext'
local iup = require 'iuplua'
require 'iupluacontrols'
require 'iupluaimglib'
local sysDisk = require 'sys.disk'
local lfs = require 'lfs'

local ipairs = ipairs
local pairs = pairs
local print = print
local type = type
local assert = assert
local error = error
local tostring = tostring
local tonumber = tonumber
local setmetatable = setmetatable
local getmetatable = getmetatable
local string = string
local table = table
local rawget = rawget
local rawset = rawset


_ENV = _M

local get_guid = luaext_.guid
------------------------------------------------------------------------
--define string
local NodeStyleIndexIds = 'NodeStyleIndexIds'
local NodeDatIndexIds = 'NodeDatIndexIds'
local NodeInheritableIndexIds = 'NodeInheritableIndexIds'
local resPath = 'res/'
------------------------------------------------------------------------
local default_style; --默认tree样式表
local init_style;

------------------------------------------------------------------------
local Tree = {}

Class = Tree
iupClass_:met(Tree)

function Tree:new(arg)
	arg = type(arg) == 'table' and arg or {}
	local t = self:met()
	t:init_control(iup.tree(init_style(arg)))
	t:init_cbfs()
	t:init_regCbfs()
	return t
end


--创建完成时，初始化矩阵相关内容
function Tree:init_cbfs()
	self:add_iup_cbf{key = 'map_cb',cbf = function(key)self:map_cb(key) end}
	self:add_iup_cbf{key = 'destroy_cb',cbf = function(key)self:destroy_cb(key) end}
	self:add_iup_cbf{key = 'togglevalue_cb',cbf =function(key)self:togglevalue_cb(key) end}
	self:add_iup_cbf{key = 'selection_cb',cbf = function(key) self:selection_cb(key) end}
	self:add_iup_cbf{key = 'button_cb',cbf = function(key) self:button_cb(key) end}
	self:add_iup_cbf{key = 'dragdrop_cb',cbf = function(key) self:dragdrop_cb(key) end}
	self:add_iup_cbf{key = 'tips_cb',cbf = function(key) self:tips_cb(key) end}
	self:add_iup_cbf{key = 'branchopen_cb',cbf = function(key) self:branchopen_cb(key) end}
	self:add_iup_cbf{key = 'branchclose_cb',cbf = function(key) self:branchclose_cb(key) end}
	self:add_iup_cbf{key = 'rightclick_cb',cbf = function(key) self:rightclick_cb(key) end}
	self:add_iup_cbf{key = 'executeleaf_cb',cbf = function(key) self:executeleaf_cb(key) end}
	self:add_iup_cbf{key = 'tips_cb',cbf = function(key) self:tips_cb(key) end}
	self:add_iup_cbf{key = 'motion_cb',cbf = function(key) self:motion_cb(key) end}
end

function Tree:init_regCbfs()
	self:reg_callback(
		'rightclick_cb',
		function(tree,id)
			self:set_markedId(id)
			self:update_selection(id)
			local sytleDat = self:get_styleDat(id) or {}
			local inheritableStyleDat = self:loop_getLastInheritableDat(id) or {}
			local rmenu =sytleDat.rmenu or inheritableStyleDat.rmenu
			if  rmenu then 
				local objRmenu = classRmenu_.new()
				local dat =  (type(rmenu) == 'table' and rmenu) or (type(rmenu) == 'function' and rmenu())
				if type(dat) == 'table' then 
					objRmenu:set_data(dat)
					return objRmenu:show(self,id)
				end
			end
		end
	)
	self:reg_callback(
		'executeleaf_cb',
		function(tree,id)
			local sytleDat = self:get_styleDat(id) or {}
			local inheritableStyleDat = self:loop_getLastInheritableDat(id) or {}
			local dlbtn =sytleDat.dlbtn or inheritableStyleDat.dlbtn
			if type(dlbtn) == 'function' then 
				return dlbtn(id,tree)
			end
		end
	)
	
	self:reg_callback(
		'selection_cb',
		function(tree,id,state)
			if self:get_kindId(id) == 'BRANCH' then return end 
			if state == 1 then 
				local sytleDat = self:get_styleDat(id) or {}
				local inheritableStyleDat = self:loop_getLastInheritableDat(id) or {}
				local lbtn =sytleDat.lbtn or inheritableStyleDat.lbtn
				if type(lbtn) == 'function' then 
					return lbtn(id,tree)
				end
			end
		end
		)
		
	self:reg_callback(
		'map_cb',
		function(tree)
			if self.data then 
				self:update()
			end
		end
	)
	self:reg_callback(
		'destroy_cb',
		function(tree)
			self.gidList = nil
		end
	)
end
-----------------------------------------------------------
--获得tree 控件
function Tree:get_tree()
	return self:get_control()
end

function Tree:set_data(data)
	self.data = data or {}
end

function Tree:get_data(data)
	return self.data 
end

-----------------------------------------------------------
function Tree:init_gidList()
	self.gidList = {}
end

function Tree:init_deleteAll()
	local dat = self:get_treeStyleDat()
	if  dat then 
		self.gidList = {[self.treeStyleId] = dat}
	end
end


function Tree:get_gidList(id)
	self.gidList = self.gidList or {}
	return  self.gidList
end

local function deepCopy(dat,newDat)
	local newDat = newDat or {}
	if type(dat) == 'table' then 
		for k,v in pairs(dat) do 
			if type(v) == 'table' then 
				newDat[k] = {}
				deepCopy(v,newDat[k])
			else 
				newDat[k] = v
			end
		end
	else 
		return dat
	end
	return newDat
end

function Tree:get_gidDat(gid,change)
	self.gidList = self.gidList or {}
	if not change then 
		return deepCopy(self.gidList[gid])
	else 
		return self.gidList[gid]
	end
end



function Tree:set_gidDat(gid,dat,append)
	self.gidList = self.gidList or {}
	self.gidList[gid] = self.gidList[gid] or {}
	if not append then 
		self.gidList[gid] = dat
	elseif  append and dat then 
		for k,v in  pairs(dat) do 
			self.gidList[gid][k] = v
		end
	end
end

function Tree:del_gidDat(gid)
	self.gidList = self.gidList or {}
	self.gidList[gid] = nil
end

function Tree:get_gidKeyDat(gid,key)
	self.gidList = self.gidList or {}
	local t = self.gidList[gid]
	if type(t) == 'table' then 
		return deepCopy(t[key])
	end
end


function Tree:set_gidKeyDat(gid,key,value)
	self.gidList = self.gidList or {}
	self.gidList[gid] = self.gidList[gid] or {}
	self.gidList[gid][key] = value
end

function Tree:create_indexGid(tab)
	local gid =get_guid()
	self.gidList = self.gidList or {}
	self.gidList[gid] = tab or {}
	return gid
end

-----------------------------------------------------------

--获得绑定节点数据创建的gid
function Tree:get_userdatGid(id)
	local userDat = self:get_userId(id)
	if type(userDat) == 'table' then 
		return userDat[NodeDatIndexIds]  and userDat[NodeDatIndexIds][1]
	end	
end

--获得节点样绑定数据表
function Tree:get_userdat(id)
	local gid  = self:get_userdatGid(id)
	if gid then 
		return  self:get_gidDat(gid)
	end
end

--绑定节点数据。
function Tree:set_userdat(dat,id)
	local gid =   self:get_userdatGid(id)
	if gid then 
		self:set_gidDat( gid,dat)
	else 
		local userDat =  self:get_userId(id) 
		userDat = type(userDat) == 'table' and userDat or {}
		userDat[NodeDatIndexIds] =userDat[NodeDatIndexIds]  or {}
		table.insert(userDat[NodeDatIndexIds],1, self:create_indexGid(dat) )
		self:set_userId(userDat,id)
	end
end

--编辑绑定节点数据。
function Tree:edit_userdatKeyDat(key,value,id)
	local gid = self:get_userdatGid(id)
	if gid then 
		self:set_gidKeyDat(gid,key,value)
	else 
		self:set_userdat({[key] = value},id)
	end
end

--获得创建节点样式时的gid
function Tree:get_styleGid(id)
	local userDat = self:get_userId(id)
	if type(userDat) == 'table' then 
		return userDat[NodeStyleIndexIds]  and  userDat[NodeStyleIndexIds][1]
	end	
end

--获得节点样式数据表
--change 是否允许改变原有数据表的值
function Tree:get_styleDat(id,change)
	local gid  = self:get_styleGid(id)
	if gid then 
		return  self:get_gidDat(gid,change)
	end
end

function Tree:set_styleDat(dat,id)
	local id = id or self:get_id()
	local gid =   self:get_styleGid(id)
	if gid then 
		self:set_gidDat( gid,dat)
	else 
		local userDat =  self:get_userId(id) 
		userDat = type(userDat) == 'table' and userDat or {}
		userDat[NodeStyleIndexIds] =userDat[NodeStyleIndexIds]  or {}
		table.insert(userDat[NodeStyleIndexIds],1, self:create_indexGid(dat) )
		self:set_userId(userDat,id)
	end
end

function Tree:edit_styleKeyDat(key,value,id)
	local gid = self:get_styleGid(id)
	if gid then 
		self:set_gidKeyDat(gid,key,value)
	else 
		self:set_styleDat({[key] = value},id)
	end
end


--获得继承节点样式的索引id
function Tree:get_inheritableStyleGid(id)
	local userDat = self:get_userId(id)
	if type(userDat) == 'table' then 
		return userDat[NodeInheritableIndexIds] and userDat[NodeInheritableIndexIds][1]
	end	
end

--获得节点样式数据表
--change 是否允许改变原有数据表的值
function Tree:get_inheritableStyleDat(id,change)
	local gid  = self:get_inheritableStyleGid(id)
	if gid then 
		return  self:get_gidDat(gid,change)
	end
end

function Tree:set_inheritableStyleDat(dat,id)
	local gid =   self:get_inheritableStyleGid(id)
	if gid then 
		self:set_gidDat( gid,dat)
	else 
		local userDat =  self:get_userId(id) 
		userDat = type(userDat) == 'table' and userDat or {}		
		userDat[NodeInheritableIndexIds] =userDat[NodeInheritableIndexIds]  or {}
		table.insert(userDat[NodeInheritableIndexIds],1, self:create_indexGid(dat) )	
		self:set_userId(userDat,id)
	end
end

function Tree:edit_styleKeyDat(key,value,id)
	local gid = self:get_inheritableStyleGid(id)
	if gid then 
		self:set_gidKeyDat(gid,key,value)
	else 
		self:set_inheritableStyleDat({[key] = value},id)
	end
end

-----------------------------------------------------------

-----------------------------------------------------------
--全局默认tree可继承样式 
function Tree:set_treeStyleDat(dat)
	if self.treeStyleId then
		self:set_gidDat(self.treeStyleId,dat,true)
	else 
		self.treeStyleId = self:create_indexGid(dat)
	end
end

function Tree:get_treeStyleDat(change)
	if self.treeStyleId then 
		return self:get_gidDat(self.treeStyleId,change)
	end
end

function Tree:set_treeStyleKeyDat(key,value)
	self.treeStyleId =self.treeStyleId or get_guid()
	self:set_gidKeyDat(self.treeStyleId,key,value)
end

function Tree:get_treeStyleKeyDat(key)
	if self.treeStyleId then 
		return self:get_gidKeyDat(self.treeStyleId,key)
	end
end

-----------------------------------------------------------

function Tree:set_rmenu(menu)
	assert(type(menu) == 'table' or type(menu) == 'function')
	self:set_treeStyleKeyDat('rmenu',menu)
end


function Tree:get_rmenu()
	return self:get_treeStyleKeyDat('rmenu')
end

function Tree:set_lbtn(fun)
	assert(type(fun) == 'function')
	self:set_treeStyleKeyDat('lbtn',fun)
end

function Tree:get_lbtn()
	return self:get_treeStyleKeyDat('lbtn')
end

function Tree:set_dlbtn(fun)
	assert(type(fun) == 'function')
	self:set_treeStyleKeyDat('dlbtn',fun)
end

function Tree:get_dlbtn()
	return self:get_treeStyleKeyDat('dlbtn')
end

-----------------------------------------------------------

function Tree:loopIds(id,rec,isDat)
	local count = self:get_childCountId(id)
	local ids = {}
	if rec then 
		local count = self:get_totalChildCountId(id)
		for i = 1,count do 
			ids[#ids+1] = id + i
		end
	else 
		local count = self:get_childCountId(id)
		local curId = id + 1
		for i = 1,count do 
			ids[#ids+1] = curId
			curId = curId + self:get_totalChildCountId(curId)+1
		end
	end
	local pos = 0;
	return function()	
		pos = pos + 1
		local curid =  ids[pos]
		if curid then 
				if isDat then 
					return self:get_styleDat(curId),self:get_userdat(curId)
				else 
					return self:get_styleGid(curId),self:get_userdatGid(curId)
				end
		end
	end
end

Tree.loopIdsDat = function(self,id,rec) return self:loopIds(id,rec,true) end
Tree.loopIdsGids = function(self,id,rec) return self:loopIds(id,rec) end 

-------------------------------------------------------------------------
--tree attributes
--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_imageLeaf('IMGPAPER') --该字符串由iup提供
	或者
	tree:set_imageLeaf('c:\\image\\test.bmp') --本地文件，必须是windows的bmp格式的文件bmp格式的文件
	详情请看IMAGELEAF属性。
--]]
function Tree:set_imageLeaf(str)
	local element = self:get_control()
	if not self:warning(element) then return end
	element.IMAGELEAF = str 
end

function Tree:set_imageBranchCollapsed(str) 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.IMAGEBRANCHCOLLAPSED = str 
end

function Tree:set_imageBranchExpanded(str) 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.IMAGEBRANCHEXPANDED = str 
end

--arg = {expanded,collapsed}
--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_imageBranch{expanded = ，collapsed = } --具体值与leaf image的设置方法类似
	详情请看 IMAGEBRANCHEXPANDED ， IMAGEBRANCHCOLLAPSED 属性。
--]]
function Tree:set_imageBranch(arg) 
	arg = arg or {}
	self:set_imageBranchExpanded(arg.expanded or arg.open) 
	self:set_imageBranchCollapsed(arg.collapsed or arg.close) 
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_fgColor('255 0 0') -- 字符串的含义是"R G B"，R、G、B的取值范围是0~255
	或者
	tree:set_fgColor('#ff0000') -- 颜色16进制表示法。效果与上等同都是红色。
--]]
function Tree:set_fgColor(str)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.FGCOLOR =  str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_bgColor('255 0 0') -- 字符串的含义是"R G B"，R、G、B的取值范围是0~255
	或者
	tree:set_bgColor('#ff0000') -- 颜色16进制表示法。效果与上等同都是红色。
--]]
function Tree:set_bgColor(str)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.BGCOLOR=  str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_hlColor('255 0 0') -- 字符串的含义是"R G B"，R、G、B的取值范围是0~255
	或者
	tree:set_hlColor('#ff0000') -- 颜色16进制表示法。效果与上等同都是红色。
--]]
function Tree:set_hlColor(str)  
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.HLCOLOR  = str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_rastersize('100x100')
--]]
function Tree:set_rastersize(str)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.rastersize = str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_size('100x100')
--]]
function Tree:set_size(str) 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.size = str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_tabTitle('Project')
--]]
function Tree:set_tabTitle(str)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.TABTITLE  = str
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_userId({test = 'Test'},1)
	注意：
		data 接收的值只能是 table、userdata、nil 这三种类型（nil 删除数据）。
		如果没有设置id这个参数，则默认设置的是当前选中节点。
--]]
function Tree:set_userId(data,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	iup.TreeSetUserId(element,id,data)
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_titleId('TestText',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。
--]]
function Tree:set_titleId(text,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	element['TITLE' .. id] = text
end


--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_colorId('255 0 0',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。
--]]
function Tree:set_colorId(color,id) 
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id  or self:get_id()
	element['COLOR' .. id] = color
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_stateId('EXPANDED',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。
--]]
function Tree:set_stateId(state,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	element["STATE" .. id] = state or "COLLAPSED"
end

--[[
设置节点字体样式。
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_titleFontStyleId('Bold',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。	
--]]
function Tree:set_titleFontStyleId(style,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	element["TITLEFONTSTYLE" .. id] = style
end
--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_imageId('IMGPAPER',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。
		如果设置的节点是branch,那么所设置的图标仅是其闭合状态下的图标样式。
--]]
function Tree:set_imageId(image,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id  or self:get_id()
	if type(image) == 'table'  then 
		if image.open then 
			self:set_imageExpandedId(image.open,id)
		end
		if image.close then 
			element['IMAGE' .. id] =image.close
		end
	else 
		element['IMAGE' .. id] =image
		
	end
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_imageExpandedId('IMGPAPER',1)
	注意：
		如果没有设置id这个参数，则默认设置的是当前选中节点。
		这里设置branch节点展开状态下的图标
--]]
function Tree:set_imageExpandedId(image,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id and tonumber(id) or self:get_id()
	element['IMAGEEXPANDED' .. id] = image
end


--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_topItem(5)
--]]
function Tree:set_topItem(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id  or self:get_id()
	element.TOPITEM = id
end

function Tree:set_showDragDrop(status)
	if not self:map_warning() then return end 
	element.SHOWDRAGDROP  = status or 'yes'
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_markedId(5)
--]]
function Tree:set_markedId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	element['MARKED' .. id] = 'YES'
end

--[[
函数功能：
	设置是否在创建文件夹节点时展开文件夹（控制当文件夹节点接收到第一个子节点时自动展开）。
	默认值'yes'
参数说明：
	status：值的类型string。'yes' or 'no'
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_addExpanded(true)
--]]
function Tree:set_addExpanded(status)
	if type(status) ~= 'string' then return end 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.ADDEXPANDED = status and 'YES' or 'NO'
end

--[[
函数功能：
	设置是否添加根节点。
	默认值是'yes'
参数说明：
	status：值的类型string。'yes' or 'no'
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_addRoot('yes')
--]]
function Tree:set_addRoot(status)
	if type(status) ~= 'string' then return end 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.ADDROOT = status
end

--[[
函数功能：
	设置自动获得焦点。在windows中点击节点时仍然会得到焦点。
	默认值是'yes'
参数说明：
	status：值的类型string。'yes' or 'no'
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_canfocus('yes')
--]]
function Tree:set_canfocus(status)
	if type(status) ~= 'string' then return end 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.CANFOCUS = status
end

--[[
函数功能：
	设置自动获得焦点。在windows中点击节点时仍然会得到焦点。
	默认值是'yes'
参数说明：
	status：值的类型string。
	可接收的值有：
		"YES" (both directions), "HORIZONTAL", "VERTICAL", "HORIZONTALFREE", "VERTICALFREE" or "NO".

使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_expand('yes')
--]]
function Tree:set_expand(status)
	if type(status) ~= 'string' then return end 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.EXPAND = status
end

--[[
函数功能：
	展开或者闭合所有文件夹节点。
参数说明：
	status：值的类型string。'yes' or 'no'
使用示例：
	local tree = require '...'.Class:new(t)
	tree:set_expandAll('yes')
--]]
function Tree:set_expandAll(status)
	if type(status) ~= 'string' then return end 
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.EXPANDALL = status
end


function Tree:set_tip(tip)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.tip = tip
end

-------------------------------------------------------------
--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local count = tree:get_count(5)
	print(type(count)) --> number
--]]
function Tree:get_count()
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	return tonumber(element.COUNT)
end


function Tree:get_totalChildCountId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id  or self:get_id()
	return tonumber(element['TOTALCHILDCOUNT' .. id]) or 0
end

function Tree:get_childCountId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id  or self:get_id()
	return tonumber(element['CHILDCOUNT' .. id]) or 0
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
		local count = tree:get_id_count(1,true)
		print(count)
		或者 
		local count = tree:get_id_count(1)
		print(count)
		
		print(type(count)) --> number
--]]
function Tree:get_id_count(id,total)
	local id = id or self:get_id()
	if id == -1 then 
		return self:get_count()
	elseif total then 
		return self:get_totalChildCountId(id)
	else
		return self:get_childCountId(id)
	end
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local depth = tree:get_depthId(1)
	print(type(depth)) --> number
	注意：
		根节点所在的层级是 0 。
--]]
function Tree:get_depthId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	return tonumber(element["DEPTH" .. id])
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local kind = tree:get_kindId(1)
	print(type(kind)) --> string
	注意：
		返回值是可能是："BRANCH"或者"LEAF"。
--]]
function Tree:get_kindId(id)	
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	return element["KIND" .. id]
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local id = tree:get_parentId(1)
	print(type(id)) --> number
	注意：
		根节点的id 是 0 。
--]]
function Tree:get_parentId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	return tonumber(element["parent" .. id])
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local state = tree:get_stateId(1)
	print(type(state)) --> string
	注意：
		返回值是可能是："EXPANDED"或者"COLLAPSED"。
--]]
function Tree:get_stateId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	return element["STATE" .. id]
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local title = tree:get_titleId(1)
	print(type(title)) --> string
--]]
function Tree:get_titleId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	return element['TITLE' .. id]
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local id = tree:get_value()
	print(type(id)) --> number
--]]
function Tree:get_value()
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	return tonumber(element.VALUE )
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	local data = tree:get_userId(3)
	print(type(id)) --> userdata or table or nil
--]]
function Tree:get_userId(id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id() 
	return iup.TreeGetUserId(element,id)
end

local function get_selected_ids(tree)
	if not tree  then error("Missing parameter !") return end 
	local str = tree.MARKEDNODES
	if type(str) ~= 'string' then return {} end
	local ids = {}
	for i = 1,#str do 
		if string.sub(str,i,i) == "+" then
			ids[#ids+1] = i-1 
		end
	end
	return ids
end

function Tree:get_id()
	if not self:map_warning() then return end 
	return self:get_value() or get_selected_ids(self:get_control())[1]
end

function Tree:get_markedNodes()
	local element= self:get_control()
	if not self:warning(element) then return end 
	return element.MARKEDNODES
end


--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:add_branchId('name',1)
	注意：
		添加的位置如果是文件夹节点，则成为该文件夹的首节点，否则会添加在文件节点下方，类似于插入操作。
--]]
function Tree:add_branchId(name,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id() 
	element["ADDBRANCH" .. id] = name
	return id  + 1
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:add_leafId('name',1)
	注意：
		添加的位置如果是文件夹节点，则成为该文件夹的首节点，否则会添加在文件节点下方，类似于插入操作。
--]]
function Tree:add_leafId(name,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()	
	element["ADDLEAF" .. id] = name
	return id + 1
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:insert_branchId('name',1)
return:
	新添加节点的id
--]]
function Tree:insert_branchId(name,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	element["INSERTBRANCH" .. id] = name
	return id +  self:get_totalChildCountId(id) + 1
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:insert_leafId('name',1)
--]]
function Tree:insert_leafId(name,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	local id = id or self:get_id()
	element["INSERTLEAF" .. id] = name
	return id +  self:get_totalChildCountId(id) + 1
end

--[[
使用示例：
	local tree = require '...'.Class:new(t)
	tree:delete_nodeId('SELECTED',1)
	注意：	
		status 的值可能为：
			"ALL": deletes all nodes, id is ignored (Since 3.1)
			"SELECTED": deletes the specified node and its children
			"CHILDREN": deletes only the children of the specified node
			"MARKED": deletes all the selected nodes (and all their children), id is ignored
--]]
function Tree:delete_nodeId(status,id)
	local element = self:get_control()
	if not self:warning(element) then return end 
	if not self:map_warning() then return end 
	status = status or "SELECTED"
	if string.lower( status) == 'all' then
		element['DELNODE'] = 'ALL' 
		self:init_deleteAll()
	elseif string.lower( status ) ~= 'marked' then
		local id = id or self:get_id()
		for styleGids,userdatGids in self:loopIdsGids(id,true) do 
			if styleGids then 
				for _,gid in ipairs(styleGids) do 
					self:set_gidDat(gid,nil)
				end
			end
			if userdatGids then 
					for _,gid in ipairs(userdatGids) do 
						self:set_gidDat(gid,nil)
					end
			end
		end
		-- self:loop_childNode{id = id,rule = function(id) self:set_gidDat(id,nil) end}
		element["DELNODE" .. id] = status
	end 
end


-------------------------------------------------------------------------
function Tree:set_selection_cb(f)
	self:reg_callback('selection_cb',f)
end

function Tree:set_branchopen_cb(f)
	self:reg_callback('branchopen_cb',f)
end

function Tree:set_branchclose_cb(f)
	self:reg_callback('branchclose_cb',f)
end

function Tree:set_dragdrop_cb(f)
	local element = self:get_control()
	if not self:warning(element) then return end 
	element.SHOWDRAGDROP  = 'yes'
	self:reg_callback('dragdrop_cb',f)
end


function Tree:update_selection(id)
	local id = id or self:get_id()
	return self:run_callbacksAll('selection_cb',self:get_control(),id,1)
end

function Tree:init_node_data(data,id)
	if id < 0 then 
		self:delete_nodeId('ALL')
	else 
		self:delete_nodeId('CHILDREN',id)
	end
	self:set_tree_data(data,id)
	if id >=0  then
		self:update_nodeStyle(id)
	end
end

function Tree:init_tree_data(data)
	if not data then return end 
	self:set_data(data)
	if self.map then 
		self:update()
	end
end

function Tree:set_treeAddNodes(data,id)
	iup.TreeAddNodes(self:get_control(), data,id)
end

function Tree:update()
	if self.map then 
		self:delete_nodeId('ALL')
		self:set_tree_data()
	end
end

--节点样式
--fname 属性是真实调用设置样式函数
--waitExe 是函数转换后等待执行
function Tree:get_styleList()
	return {
		userdata = {fname = 'set_userdat',};
		color = {fname = 'set_colorId',};
		image = {fname = 'set_imageId',};
		state = {fname = 'set_stateId',};
		fontstyle =  {fname = 'set_titleFontStyleId',};
		title = {fname = 'set_titleId',};
		rmenu = {waitExe = true};
		lbtn = {waitExe = true};
		dlbtn = {waitExe = true};	
	}
end

function Tree:get_globalStyleList()
	return {
		rmenu = {waitExe = true};
		lbtn = {waitExe = true};
		dlbtn = {waitExe = true};	
		--global
		imageLeaf = {fname = 'set_imageLeaf'};
		iconFileType = {fname = 'set_iconFileType',waitExe = true};
		imageBranch = {fname = 'set_imageBranch'}; 
		imageBranchCollapsed = {fname = 'set_imageBranchCollapsed'};
		imageBranchExpanded = {fname = 'set_imageBranchExpanded'};
	}

end


function Tree:init_fileTypeIcon(id)
	local id = id or self:get_id()
	local title = self:get_titleId(id) or ''
	local fileType =  string.match(title,'.+%.([^%.]+)')
	if fileType then 
		local bmpFile = resPath .. fileType .. '.bmp'
		return  iup.LoadImage(bmpFile)
	end
	local bmpFile = resPath ..  'default.bmp'
	return iup.LoadImage(bmpFile)
end

--根据节点的文件类型设置图标样式
function Tree:set_iconFileType(val)
	if val  then 	
		 self:set_treeStyleKeyDat('image',function(id) 
			if self:get_kindId(id) == 'LEAF' then 
				return self:init_fileTypeIcon(id) 
			end
		end)
	end
end

function Tree:turn_fun(key,styleFunTab,dat,id)
	local val;
	if dat.action and dat.file then 
		local mod = sysDisk.file_require(dat.file)
		if mod then 
			val = mod[dat.action]
		end
	end
	if not val then return dat  end 
	if id and id == -1 then 
		if not styleFunTab.waitExe then 
			val = val()
		end
		self:set_treeStyleKeyDat(key,val)
	else 
		id = id or self:get_id()
		local gid = self:get_styleGid(id)
		if not gid then return end 
		if not styleFunTab.waitExe then 
			val = val()
		end
		self:set_gidKeyDat(gid,key,val)
	end
	return val
end

function Tree:update_nodeStyle(id)
	local id = id or self:get_id()
	local inheritableStyleDat,inheritableId = self:loop_getLastInheritableDat(id)
	local styleDat = self:get_styleDat(id)
	local curId = id
	for k,v in pairs(self:get_styleList()) do 
		local val = styleDat and styleDat[k]
		if not val then 
			val =  inheritableStyleDat and inheritableStyleDat[k]
			curId = inheritableId
		end
		if type(val) == 'table' then 
			val = self:turn_fun(k,v,val,curId)
		end
		if val and v.fname  then 
			if type(val) == 'function' and not v.waitExe then 
				val = val(id)
			end
			self[v.fname](self,val,id)
		end
	end
end

function Tree:update_treeStyle()
	local dat = self:get_treeStyleDat()
	for k,v in pairs(self:get_globalStyleList()) do 
		local val = dat[k]
		if type(val) == 'table'  then 
			val = self:turn_fun(k,v,val,-1)
		end
		if val and v.fname then 
			if type(val) == 'function' and not v.waitExe then 
				val = val(id)
			end
			self[v.fname](self,val,id)
		end
	end
end

function Tree:init_nodeStyleDat(attrTab,id)
	if not attrTab then return end
	local id = id or self:get_id()
	local userdata = attrTab.userdata
	self:set_styleDat(attrTab,id)
end

--[[
data style:
	{
		--attributes = {color= ,imageLeaf = '',...}; -- 可选的继承属性表。子节点自动继承样式
		{--第一个节点
			attributes = {title = '1'};--代表当前节点信息的属性表必须存在title属性
			{--代表当前节点为文件夹节点
				--attributes = {} -- 可选的继承属性表。子节点自动继承样式
				{attributes = {title = 3}}；--文件夹内部第一个节点。
				{attributes = {title = 4}}；--文件夹内第二个节点
			}
		}，
		{
			--第二个节点
			attributes = {title = '2'}
			
		}
	}
--]]
function Tree:loop_getLastInheritableId(id)
	local dat = self:get_inheritableStyleDat(id)
	if dat then return id end 
	if self:get_depthId(id)  == 0  then  
		return -1
	end
	return self:loop_getLastInheritableId(self:get_parentId(id))
end

function Tree:loop_getLastInheritableDat(id)
	local dat = self:get_inheritableStyleDat(id,true)
	if dat then 
		local temp = {}
		setmetatable(temp,{__index = dat})
		return temp,id 
	end 
	if self:get_depthId(id)  == 0  then  	
		return self:get_treeStyleDat(true),-1
	end
	return self:loop_getLastInheritableDat(self:get_parentId(id))
end

function Tree:set_metDat(lastInheritableId,dat)
	local temp;
	if  not lastInheritableId or  lastInheritableId == -1 then 
		temp = self:get_treeStyleDat(true) 
	else
		temp =  self:get_inheritableStyleDat(lastInheritableId,true)
	end
	if temp then 
		setmetatable(dat,{__index = temp})
	end
end

 function Tree:set_tree_data(data,id,lev,lastInheritableId)
	if not lev then 
		data = data or self.data
		id = id or -1
	end
	if type(data) ~= 'table' then return end 
	if data.attributes then 
		if id == -1  then 
			self:set_treeStyleDat(data.attributes)
			self:update_treeStyle()
			lastInheritableId =  -1
		else 
			if not lastInheritableId then 
				lastInheritableId = self:loop_getLastInheritableId(id)
			end
			self:set_inheritableStyleDat(data.attributes,id)
			local dat = data.attributes
			self:set_metDat(lastInheritableId,dat)
			lastInheritableId =  id
		end
	end
	
	 if  #data == 0 then return end 
	 local curId = id
	for k ,v in ipairs(data) do 
		assert(v and v.attributes and v.attributes.title)
		if k == 1 then 
			if #v ~= 0 then 
				self:add_branchId(v.attributes.title,curId)
			else 
				self:add_leafId(v.attributes.title,curId)
			end
		else
			if #v ~= 0 then 
				self:insert_branchId(v.attributes.title,curId)
			else
				self:insert_leafId(v.attributes.title,curId)
			end
			curId = curId + self:get_totalChildCountId(curId)
		end
		curId = curId + 1
		self:init_nodeStyleDat(v.attributes,curId)
		self:set_tree_data(v[1],curId,true,lastInheritableId)
		self:update_nodeStyle(curId)
	end
 end

-------------------------------------------------------------------------
--callbacks

function Tree:destroy_cb(key)
	local element = self:get_control()
	if not self:warning(element) then return end 
	local temp = self
	function element:destroy_cb()
		return temp:run_callbacks(key,self)
	end
end

function Tree:togglevalue_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:togglevalue_cb(id, state) 
		return temp:run_callbacks(key,self,id,state)
	end
end

function Tree:selection_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:selection_cb(id, state) 
		if state == 1 then 
			return temp:run_callbacks(key,self,id,state)
		end
	end
end

function Tree:button_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:button_cb(button,pressed,x,y,str)
		return temp:run_callbacks(key,self,button,pressed,x,y,str)
	end
end

function Tree:rightclick_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:rightclick_cb(id) 
		return temp:run_callbacks(key,self,id)
	end
end

function Tree:dragdrop_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:dragdrop_cb(drag_id, drop_id, isshift, iscontrol) 
		local status = temp:run_callbacks(key,self,drag_id, drop_id, isshift, iscontrol)
		return status
	end
end


function Tree:branchopen_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:branchopen_cb(id)
		return temp:run_callbacks(key,self,id)
	end
end

function Tree:branchclose_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:branchclose_cb(id)
		return temp:run_callbacks(key,self,id)
	end
end

function Tree:executeleaf_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:executeleaf_cb(id)
		return temp:run_callbacks(key,self,id)
	end
end

function Tree:motion_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:motion_cb(x,y,status)
		return temp:run_callbacks(key,self,x,y,status)
	end
end


function Tree:tips_cb(key)
	local iupControl = self:get_control()
	local temp = self
	if not self:warning(iupControl) then return end 
	function iupControl:tips_cb(x,y)
		return temp:run_callbacks(key,self,x,y)
	end
end

--]]
---------------------------------------------------------------------------
--二〇一八年十二月二十一日
function Tree:get_treePath(id)
	local id = id or self:get_id()
	local title = self:get_titleId(id)
	if self:get_kindId(id) == 'BRANCH' then 
		title = title .. '/'
	end
	if id == 0 then return title end
	return self:get_treePath(self:get_parentId(id))   .. title
end

function Tree:get_childTitleId(title,pid)
	local  pid = pid or self:get_id()
	local count = self:get_childCountId(pid)
	if count == 0 then return end 
	local curId = pid + 1
	for i = 1,count do 
		if self:get_titleId(curId) == title then 
			return curId
		end
		curId = curId + 1 + self:get_totalChildCountId(curId)
	end
end

---------------------------------------------------------------------------
--
default_style = {}
default_style.addexpanded = "NO";
default_style.expand=   "YES";
default_style.EXPANDALL=   "NO";
 default_style.showrename = "NO";
default_style.MARKMODE =  "SINGLE";
default_style.IMAGELEAF = "IMGPAPER";
default_style.ADDROOT = 'YES'; 
default_style.title0 = 'Tree'; 
--[[
default_style.INFOTIP = 'no'; 
default_style.TIP = 'tips'; 
--default_style.TIPVISIBLE = 'YES'; 
default_style.TIPBALLOONTITLEICON  = '1'; 
default_style.TIPBALLOON = 'YES'; 
default_style.TIPBALLOONTITLE = 'Tip'; 
default_style.TIPDELAY = '10000'; 
--]]

init_style = function(userStyle)
	local userStyle = userStyle or {}
	for k,v in pairs(default_style) do 
		if not userStyle[k] then 
			userStyle[k]  = v
		end
	end
	return userStyle
end

--[[
测试数据：
{
	attributes = { --这里可以设定Tree的全局默认样式。注意仅能设定tree map后的属性
		color = '0 0 255';
		rmenu = {
			{title = '1'};
			{title = '2'};
		};
	};
	{
		attributes = {
			title = "0"; --节点id为0；
			color = '255 0 0';
		};
		{
			attributes = { --title为0的节点绑定的继承样式表。
				 state = 'COLLAPSED';
				 fontstyle = 'Bold, Italic';
			};
			{
				attributes = {
					title = "1";
					 -- color = '0 255 0';
				};
				{
					attributes = {  --title为1的节点绑定的继承样式表。
						color = '0 255 0';
						fontstyle = 'Bold';
						rmenu = {
							{title = '3'};
							{title = '4'};
						};
					};
						{attributes = {
						title = "2";
						-- color = '0 255 0';
					};};
					{attributes = {
					title = "3";
					-- color = '0 255 0';
				};};
				};
			};
			{
				attributes = {
					title = "4";
					-- color = '0 255 0';
				};
			}
		};
	};
	{
		attributes = {
			title = "5";
		};
	};

}
--]]

-----------------------------------------------------------------------
