--[[
/*
*Author:Sun JinYang
*Begin:
*Description:
*	
*Import Update Record:��Time Content��
*/
--]]
--[[
����淶��
	(����)position:ֵΪstring���ͣ�����ͼ���λ����Ϣ��ȱʡΪ�����µ�һ�С�ֵ����ʽΪ"lin:col" ���ڵ�lin �� ��col�к�ʼ��Ӱ�ť��
			lin��ֵΪ0 ����뵽��һ�С�ֵ�������ԭ����ʽ���ݵ��������������б��ֲ��䣬��ʾʱ���Զ�������С�
			col:  ֵΪ0��1 ʱ����ӵ�ǰ�е����׿�ʼ��ӡ����ֵ���ڵ�ǰ�����õİ�ť��ʱ����ʾʱ���Զ�β��׷�ӡ���������Ȼ����ԭʼλ�á���������λ���Ѵ��ڰ�ť����ԭ�еİ�ť��λ���Զ������λ��
	name:ֵΪstring���ͣ������������Ƶ�ǰ��������ӦͼƬ���ơ��������������������������µİ�ť����Ϊ��ǰ���������������ڵ��������������е��ļ��е����ƣ���
		ע�⣺
			name��Ҫ��֤��Ψһ�ԡ�ʹ��"."��Ϊ���ӷ��š�ͨ����ʽΪ������֯����.��������ơ�����֯����Ҳ�����á�.���ָ��� ���磺"AP.Greenmark"
			����ʹ��ID��
				SYS��ϵͳ����ID
				AP��ϵͳ���в��ID��
			ͬһ���������ڲ��İ�ť����������£�
				���ݲ���Ĳ���˳��β��׷��
				���û��""��ϵͳ�����Զ���ӷָ�����
				�����Ҫ����ʱ����Ϊһ������btns��Ӧ����������λ���"".ϵͳ���Զ��ϲ�ͷβ����ķָ�����
	plugin:ֵΪstring���ͣ����õ�ǰ�����Ĳ�����ơ�
		ע�⣺ж�ز��ʱ����������д��ڷǵ�ǰж�ز����������ʹplugin��ͬҲ�����Զ�ɾ�����û���Ҫ�Լ��ֶ�����toolbar����ʽ��
	btns:ֵΪ����table ����ÿһ�����ӱ��ɣ�ÿ�������һ����ť���������ֵΪ''����Ŀ���ʾ�˴���ʾΪ�ָ���š�ÿ����ť�����ݽṹ���£�������ʽ�����еĽṹһ�£�
		icon �� ֵΪstring���ͣ���ť��ͼ��
			���磺'res/toolbar/property_brush.bmp'; --����ĸ��/���õ������·����������ϵͳ�ṩ���زĿ�
		keyword ��ֵΪstring���ͣ����������ݱ�
			���磺'AP.REI_SingaporeGM.PropertyBrush';
		name ��ֵΪstring���ͣ���ť��ʾ��tip��Ϣ��
			���磺'Property Brush';
		plugin��ֵΪstring���ͣ���ǰ������ơ�
���ݽṹ��
	[1]...:ֵΪtable���ͣ����鲿������ȷ����Ӽ��й�������table�����ݽṹ���£�
		name��ֵΪstring���ͣ������µĹ������б��⡣
		plugin��ֵΪstring���ͣ���ǰ������ơ�
		language��
		[1]..:ֵΪtable���ͣ����鲿������ȷ�����й�����������Щ��ť��table�е����ݽṹ���£�
			name:ֵΪstring���ͣ���ť��ʾ��tip��Ϣ��
			keyword:ֵΪstring���ͣ����������ݱ�
			icon:ֵΪstring���ͣ���ť������ͼ���ļ���ע�⣺�������ϵͳ��������ť�ṩ���ز���ֱ���ṩ��ͼ����ļ����ɼ��ɡ�����ǲ�������ṩ��ͼ����ָ������ڵ����·�������磺greenmark�����ͼ���λ����greenmark/res/test.bmp
			plugin��ֵΪstring���ͣ���ǰ������ơ�
			language��
---------------------------------------------------------
2018-09-14 13:32:32 ˼��
	���������ԭ�е�position���ԣ�������ɲ�ͬ���֮��İ�ťλ�ó�ͻ�����ǲ�������name��λ�У�Ȼ���������һ��ģʽ������ͻ�Ĳ��뵽ָ��λ�á�
		
�ӿں�����
ʹ�÷�ʽ��
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
local init_toolbarIds;--toolbar ����ʽ�ļ�
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
--plugin toolbar Э��
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
--ȱʡΪinstall
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