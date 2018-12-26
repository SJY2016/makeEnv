--[[
/*
*Author:Sun JinYang
*Begin:
*Description:
*	
*Import Update Record:（Time Content）
*/
--]]
--[[
插件规范：
	(待定)position:值为string类型，设置图标的位置信息。缺省为创建新的一行。值得样式为"lin:col" 。在地lin 行 第col列后开始添加按钮。
			lin：值为0 则插入到第一行。值如果超过原有样式数据的行数则在数据中保持不变，显示时会自动添加新行。
			col:  值为0或1 时代表从当前行的行首开始添加。如果值大于当前行设置的按钮数时，显示时会自动尾部追加。数据中依然保存原始位置。如果插入的位置已存在按钮，则原有的按钮的位置自动向后移位。
	name:值为string类型，可以用来控制当前工具条对应图片名称、可以用来被其他插件索引添加新的按钮、作为当前工具条的组名（在调整工具条界面中的文件夹的名称）。
		注意：
			name需要保证其唯一性。使用"."作为连接符号。通常格式为：“组织名称.具体的名称”（组织名称也可以用“.”分隔） 例如："AP.Greenmark"
			不可使用ID：
				SYS：系统自有ID
				AP：系统自有插件ID。
			同一个工具条内部的按钮排序规则如下：
				根据插件的插入顺序尾部追加
				如果没有""则系统不会自动添加分隔符号
				插件想要插入时独立为一组需在btns对应的数组内首位添加"".系统会自动合并头尾多余的分隔符号
	plugin:值为string类型，设置当前依赖的插件名称。
		注意：卸载插件时，如果该行中存在非当前卸载插件的内容则即使plugin相同也不会自动删除。用户需要自己手动调解toolbar的样式。
	btns:值为数组table 表内每一项由子表构成，每个表代表一个按钮，如果出现值为''的条目则表示此处显示为分割符号。每个按钮的数据结构如下：（与样式数据中的结构一致）
		icon ： 值为string类型，按钮的图标
			例如：'res/toolbar/property_brush.bmp'; --首字母是/则用的是相对路径，否则用系统提供的素材库
		keyword ：值为string类型，关联的数据表。
			例如：'AP.REI_SingaporeGM.PropertyBrush';
		name ：值为string类型，按钮显示的tip信息。
			例如：'Property Brush';
		plugin：值为string类型，当前插件名称。
数据结构：
	[1]...:值为table类型，数组部分用来确定添加几行工具条。table中数据结构如下：
		name：值为string类型，设置新的工具条行标题。
		plugin：值为string类型，当前插件名称。
		language：
		[1]..:值为table类型，数组部分用来确定该行工具条包含哪些按钮。table中的数据结构如下：
			name:值为string类型，按钮显示的tip信息。
			keyword:值为string类型，关联的数据表。
			icon:值为string类型，按钮关联的图标文件。注意：如果采用系统工具条按钮提供的素材则直接提供该图标的文件名成即可。如果是插件自身提供的图标请指明插件内的相对路径。比如：greenmark插件内图标的位置是greenmark/res/test.bmp
			plugin：值为string类型，当前插件名称。
			language：
---------------------------------------------------------
2018-09-14 13:32:32 思考
	如果利用与原有的position属性，则易造成不同插件之间的按钮位置冲突。考虑采用利用name定位行，然后行内设计一个模式允许不冲突的插入到指定位置。
		
接口函数：
使用方式：
local cur = require ''.Class:new(oldTab or nil)
cur: ...
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysSetting =  require ('sys.setting')
local sysMsgId =  require ('sys.msg.id')
local sysKeyword = require ('sys.keyword')
local sysDisk = require 'sys.disk'
local lfs = require 'lfs'


local setmetatable = setmetatable
local tonumber = tonumber
local type =type
local print =print
local assert = assert
local type =type
local ipairs = ipairs
local pairs = pairs
local next = next
local table = table
local string = string

local sub = string.sub
local sort = table.sort
local unpack =  table.unpack

local trace_out = trace_out;
local remove_toolbar = remove_toolbar
local crt_toolbar = crt_toolbar;
local frm = frm;
local BTNS_SEP = BTNS_SEP;
local TBSTATE_ENABLED = TBSTATE_ENABLED;
local BTNS_CHECK = BTNS_CHECK;


--[[

TBSTATE_CHECKED  The button has the TBSTYLE_CHECK style and is being clicked. 
TBSTATE_ELLIPSES  Version 4.70. The button's text is cut off and an ellipsis is displayed. 
TBSTATE_ENABLED  The button accepts user input. A button that doesn't have this state is grayed. 
TBSTATE_HIDDEN  The button is not visible and cannot receive user input. 
TBSTATE_INDETERMINATE  The button is grayed. 
TBSTATE_MARKED  Version 4.71. The button is marked. The interpretation of a marked item is dependent upon the application.  
TBSTATE_PRESSED  The button is being clicked. 
TBSTATE_WRAP  The button is followed by a line break. The button must also have the TBSTATE_ENABLED state. 

--]]
_ENV = _M
--------------------------------------------------

local Toolbar = {} 
Class = Toolbar

--------------------------------------------------
local init_toolbarIds;--toolbar 的样式文件
local update_toolbarIds;
--------------------------------------------------

function Toolbar:new(t)
	t = t or {}
	setmetatable(t,self)
	self.__index = self
	return t
end

local function sortKeys(dat)
	local tempTab = {}
	for k,v in pairs(dat) do 
		if type(k) == 'number'  then 
			tempTab[#tempTab+1] = k
		end
	end
	
	table.sort(tempTab)
	return tempTab
end
--------------------------------------------------



function update(styleDat)
	remove_toolbarIds()
	if type(styleDat) ~= 'table' or #styleDat == 0 then return end 
	for _,toolbar in ipairs(styleDat) do 
		if type(toolbar) == 'table' then 
			self:create_toolbar(toolbar)
		end
	end
end


--------------------------------------------------



function Toolbar:create_toolbar(dat)
	if not dat or dat.hide then return end 
	local btns = {}
	local id,btnDat,fsStyle;
	local iconPos = 0 ; 
	local images = {}
	
	local tempTab =dat -- sortKeys(dat)
	if #tempTab==0 then return end 
	
	-- for k,btn in ipairs(dat) do 
	for k,btn in ipairs(tempTab) do 
		-- btn = dat[v]
		if type(btn) == 'table' and btn.name  then 
		
			btnDat = sysKeyword.get_keywordDat(btn.keyword)  or {}
			local icon =  btn.icon or btnDat.icon
			
			images[#images+1] =icon
			
			if not btn.hide then 
				id = sysMsgId.get_command_id();
				sysMsgId.map(id,btn.keyword);
				fsStyle = (btn.checkbox or btnDat and btnDat.checkbox)  and  BTNS_CHECK
				btns[#btns+1] = {
					iBitmap = iconPos;
					idCommand = id,
					iString = btn.name ;
					fsState  = TBSTATE_ENABLED,
					fsStyle = fsStyle;
				}
			end
			iconPos = iconPos + 1;
		else
			if #btns ~= 0 and #btns ~=  #tempTab and btns[#btns].fsStyle ~= BTNS_SEP then 
				btns[#btns+1] = {iString = '',fsStyle = BTNS_SEP,fsState = TBSTATE_ENABLED}
			end
		end
	end
	local bmpname = resource:get_toolbarBmpname{name = dat.name or ('toolbar' .. pos),icons = images,}
	
	local id = sysMsgId.get_command_id()
	add_toolbarId(id)
	crt_toolbar(frm,{
		id = id;
		bmpname = bmpname;
		nbmps = 1;
		buttons = btns;
	})
end

init_toolbarIds = function()
	local toolbarIds = {};
	return function()
		for k,v in ipairs (toolbarIds) do 
			remove_toolbar(frm,v)
		end
		toolbarIds = {}
	end,
	function(id)
		toolbarIds[#toolbarIds + 1] = id
	end
end
remove_toolbarIds,add_toolbarId = init_toolbarIds()

--[==[
--------------------------------------------------
--plugin toolbar 协议
--arg = {name = ,dat=}
function Toolbar:plugin_install(arg)
	local dat = arg.dat and arg.dat.toolbar 
	if type(dat) ~= 'table' then return end 
	local name = dat.name
	local plugin = arg.name
	local btns = dat.btns 
	
	local styleDat = style:get() or {}
	local positionLin= #styleDat + 1
	--[[
	if dat.position then 
		local lin,col =  string.match(dat.position,'(%d+):(%d+)') 
		positionLin = lin and tonumber(lin) or positionLin
		positionCol = col and tonumber(col) or positionCol
		if positionLin == 0 then 	
			table.insert(styleDat,1,{name = name,plugin = plugin})
			positionLin = 1
		end
		positionCol = positionCol == 0 and 1 or positionCol
	end
	--]]
	for k,v in ipairs(styleDat) do 
		if v.name ==  dat.name then 
			positionLin = k
			break;
		end
	end
	
	styleDat[positionLin] = styleDat[positionLin] or {name = name,plugin = plugin}
	local insertLinDat = styleDat[positionLin]
	for k,btn in ipairs(btns) do 
		
		if type(btn) == 'table'then 
			btn.plugin = plugin
		else 
			btn = {plugin = plugin}
		end
		insertLinDat[#insertLinDat+1] = btn
	--	if insertLinDat[positionCol]  then 
	--		table.insert(insertLinDat,positionCol,btn)
	--	else 
	--		insertLinDat[positionCol] = btn
	--	end
	--	positionCol = positionCol+ 1
	end
	
	return style:save(styleDat)
end

function Toolbar:plugin_uninstall(name)
	local styleDat = style:get() or {}
	local newDat = {}
	
	local curLin = 0
	for k,v in ipairs(styleDat) do  
		local t,curCol = {},0;
		for m,n in ipairs(v) do 
			if not n.plugin or n.plugin ~= name then 
				curCol = curCol + 1
				t[curCol] = n
			end
		end
		
		if #t ~= 0 or (not v.plugin)  or (v.plugin and v.plugin ~= name) then 
			for m,n in pairs(v) do 
				if type(m) ~= 'number' then 
					t[m] = n
				end
			end
			curLin = curLin + 1
			newDat[curLin] = t
		end
		-- end
	end
	style:save(newDat)
end

--arg = { name,--status,--dat,}
--缺省为install
function Toolbar:reg_pluginUpdateCbf(arg)
	assert(type(arg) == 'table')
	if arg.status and arg.status == 'uninstall' then 
		self:plugin_uninstall(arg.name)
	else 
		self:plugin_install{name = arg.name,dat = arg.dat}
	end
end


-- plugin:reg_cbf(Toolbar.update_plugin)

--------------------------------------------------

--



lang:reg_update(
	function()
		local toolbar = Class:new()
		toolbar:update()
	end
)

--]==]