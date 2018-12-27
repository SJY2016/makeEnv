--[[
/*
*Author:Sun JinYang
*Begin:2018��12��27��
*Description:
*	����ļ���������ͬģ�� ����ʱkeyword����
*Import Update Record:��Time Content��
*/
--]]
--[[
���ݽṹ��
	toolbar & menu :
		remark:ֵΪstring���ͣ����õı�ע��Ϣ��
		view:ֵΪtrue ʱ������ͼ����ʱ����Ӧ onClick ������
		frame:ֵΪtrue ʱ����ͼ������ʱ����Ӧ onClick ������
		file:ֵΪstring ���ͣ���Ӧ������ŵ��ļ�������ʡ��ֱ����action�н������ã���
		icon:ֵΪstring���ͣ�ͼ���ļ�·��������:'res/a.bmp' ,��
			ע�⣺ͨ����������ť��ͼ��Ϊ16x16��bmp ��ʽ���ļ�.
		action:ֵ���ܴ��ڵ������У�function��string������table,������Ӧ������
			ע�⣺string���� ���������ƻ��� �����ļ�·�������������ļ�·���ĺ������ڵ��ļ�����Ϊ.lua�ļ�����
				���� 
					��·���ĺ����ַ���"a/b/action.onClick"����a/ b/�ļ����µ�action.lua �ļ��а����ɹ��ⲿ���õ�onClick����
				��ͬ��
					file���Ժ� action ���Ժ���ʹ�ã�file = "a/b/action.lua"  action = 'onClick'
						
			
		enable:ֵΪboolean���ͻ��߷���booleanֵ��function���ͣ���ť�Ƿ���������״̬��������ûҵ�״̬����ȱʡֵΪtrue
		-- checkbox:ֵΪboolean���͡�ȱʡΪ���º���������,����ӡ�
		-- shortcut:,�����
		-- hotkey:ֵΪstrig���ͣ���Ӧ�ȼ���Ϣ,�����
	leftDlg :
		hwnd :�ο�action��������Ҫ����iup �ؼ��ԡ�ͨ��Ϊ iup.frame ��iup.vbox
		onInit �ο�action����ʼ�����ݻص�����
		onLoad �ο�action������ hwnd ǰ��������
		onUnload �ο�action��ж�� hwnd ��������
������ʽ��
	local keywords = {
		['Page'] = { --page : left dlg
			tabtitle = 'GreenMark';
			file = 'browser/main.lua';
			hwnd=  {type = 'function',value ="get_hwnd"}; 
			onInit=  {type = 'function',value ="on_init"}; 
			-- onLoad=  {type = 'function',value ="on_load"}; 
			onUnload=  {type = 'function',value ="on_unload"}; 
		};
		['Menu'] = {
			view = true;
			frame = true;
			action = "action.new_file";
		};
		['Toolbar'] = {
			view = true;
			frame = true;
			icon = 'res/save.bmp';
			action ="action.open_file";
	}
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = require 'sys.tools'
local sysDisk = require 'sys.disk'
local sysSetting = require 'sys.setting'
local lfs = require 'lfs'

local setmetatable = setmetatable
local type =type
local print =print
local assert = assert
local ipairs = ipairs
local pairs = pairs
local next = next
local string = string
local sub = string.sub
local sort = table.sort
local unpack =  table.unpack
local error = error
local table = table


_ENV = _M

local init_keywordDat;
local keywordDat;
--------------------------------------------------


local functionKeys = {
	action = true;
	hwnd = true;
	onInit = true;
	onLoad = true;
	onUnload = true;
}

init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	local db = dat 
	for k,keyDat in pairs(db) do 
		keywordDat[k] = {}
		setmetatable(keywordDat[k],
			{
				__index = function(tab,key)
					local val = keyDat[key]
					local file = keyDat.file
					if not val then return end 
				
					if functionKeys[key] then	
						if type(val) ~= 'table' and type(val) ~= 'function' and type(val) ~= 'string'  then return val end 
						local mod,fun;
						if type(val) == 'function' then 
							fun = val
						else
							local action = type(val) == 'table' and val.action or val
							local useFile =  type(val) == 'table' and val.file or file
							if type(action) == 'function' then 
								fun = action
							else 
								local actionFile,actionCmd = string.match(action,'([^%.]+)'),string.match(action,'%.(.+)') --action �ַ����п��ܰ����ļ���Ϣ
								if actionCmd then 
									--���actionCmd ���� ����ζ�Ÿ��ַ�������ʽΪ "str1.str2" str2�п��ܼ���������.��str1�п��ܰ�����/��
									mod =  sysDisk.file_require(actionFile .. '.lua')
									--ע���ʱ�п���str1���������ļ����п���Ҳ�������һ����.��ʱ�����mod������ϵͳ��Ϊ�ض����ļ�·��,���Կ�����Ա�ڿ���ʱ����ʹ����������������ַ���
								end
								if not mod and useFile then 
									--����mod �����ڵ���������������ʹ��table�ڵ�file ����ʹ����һ�㶨���file����ֵ��������������ʹ��������action��Ӧ���ַ���
									mod =  sysDisk.file_require(useFile)
									actionCmd = action
								end
								if mod and actionCmd then 
									fun = type(mod[actionCmd]) == 'function' and mod[actionCmd]
								end
							end
						end
						
						if fun then 
							-- if type(val) == 'table' and val.exe then 
								-- fun = fun()
							-- end
							keyDat[key] =fun
						else 
							keyDat[key] = function() error('Fuction Missing !') end
						end
						return keyDat[key] 
					end
					return val
				end
			}
		)
	end	
end

get_keywordDat  = function(key)
	if not keywordDat then return end
	if not key then return end
	if  type(keywordDat[key]) == 'table'  then 
		return keywordDat[key]
	end
end


sysSetting.reg_cbf('keyword',init_keywordDat)
--]]
--------------------------------------------------
--[===[
--[[
/*
*Author:Sun JinYang
*Begin:2018��12��27��
*Description:
*	����ļ���������ͬģ�� ����ʱkeyword����
*Import Update Record:��Time Content��
*/
--]]
--[[
���ݽṹ��
	toolbar & menu :
		remark:ֵΪstring���ͣ����õı�ע��Ϣ��
		view:ֵΪtrue ʱ������ͼ����ʱ����Ӧ onClick ������
		frame:ֵΪtrue ʱ����ͼ������ʱ����Ӧ onClick ������
		file:ֵΪstring ���ͣ���Ӧ������ŵ��ļ�������ʡ��ֱ����action�н������ã���
		icon:ֵΪstring���ͣ�ͼ���ļ�·��������:'res/a.bmp' ,��
			ע�⣺ͨ����������ť��ͼ��Ϊ16x16��bmp ��ʽ���ļ�.
		action:ֵΪfunction���ͻ���string����,�������ִ�еĺ�����
			ע�⣺string���� ���������ƻ��� �����ļ�·�������������ļ�·���ĺ������ڵ��ļ�����Ϊ.lua�ļ�����
				���� 
					��·���ĺ����ַ���"a/b/action.onClick"����a/ b/�ļ����µ�action.lua �ļ��а����ɹ��ⲿ���õ�onClick����
				��ͬ��
					file���Ժ� action ���Ժ���ʹ�ã�file = "a/b/action.lua"  action = 'onClick'
						
			
		enable:ֵΪboolean���ͻ��߷���booleanֵ��function���ͣ���ť�Ƿ���������״̬��������ûҵ�״̬����ȱʡֵΪtrue
		-- checkbox:ֵΪboolean���͡�ȱʡΪ���º���������,����ӡ�
		-- shortcut:,�����
		-- hotkey:ֵΪstrig���ͣ���Ӧ�ȼ���Ϣ,�����
	leftDlg :
		onInitDlg
		onInitDat
		onLoad
		onUnload
������ʽ��
	local keywords = {
		['Page'] = { --page : left dlg
			tabtitle = 'GreenMark';
			file = 'browser/main.lua';
			hwnd=  {type = 'function',value ="get_hwnd"}; 
			onInit=  {type = 'function',value ="on_init"}; 
			-- onLoad=  {type = 'function',value ="on_load"}; 
			onUnload=  {type = 'function',value ="on_unload"}; 
		};
		['Menu'] = {
			view = true;
			frame = true;
			action = "action.new_file";
		};
		['Toolbar'] = {
			view = true;
			frame = true;
			icon = 'res/save.bmp';
			action ="action.open_file";
	}
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = require 'sys.tools'
local sysDisk = require 'sys.disk'
local sysSetting = require 'sys.setting'
local lfs = require 'lfs'

local setmetatable = setmetatable
local type =type
local print =print
local assert = assert
local ipairs = ipairs
local pairs = pairs
local next = next
local string = string
local sub = string.sub
local sort = table.sort
local unpack =  table.unpack
local error = error
local table = table


_ENV = _M

local init_keywordDat;
local keywordDat;
--------------------------------------------------


local functionKeys = {
	action = true;
	
}

init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	local db = dat --sysTools.deepcopy(dat)
	for k,keyDat in pairs(db) do 
		keywordDat[k] = {}
		setmetatable(keywordDat[k],
			{
				__index = function(tab,key)
					local cur = keyDat[key]
					if not cur then return end 
					if type(cur) == 'table' and cur.type == 'function'  and cur.value == 'string'  then 					
						local tab = keyDat;
						local modFun;
						if string.find(cur.value,'%.') then 
							local fileName,funName =string.match(cur.value,'(.+)%.'),string.match(cur.value,'.+%.([^%.]+)')
							local file = fileName .. '.lua'
							local mod = sysDisk.file_require(file)
							if mod and mod[funName] then 
								modFun = mod[funName]
							end
						elseif cur.file then 
							local file = cur.file
							local mod = sysDisk.file_require(file)
							if mod and mod[cur.value] then 
								modFun = mod[cur.value]
							end
							
						elseif tab.file then 
							local file = tab.file
							local mod = sysDisk.file_require(file)
							if mod and mod[cur.value] then 
								modFun = mod[cur.value]
							end
						end
						if cur.exe and modFun then 
							keyDat[key] =modFun()
						elseif modFun then 
							keyDat[key] =modFun
						else 
							keyDat[key] = function() error('Fuction Missing !') end
						end
						return keyDat[key] 
					elseif functionKeys[key] then
						
					end
					return cur
				end
			}
		)
	end	
end

get_keywordDat  = function(key)
	if not keywordDat then return end
	if not key then return end
	return type(keywordDat[key]) == 'table' and keywordDat[key]
end


sysSetting.reg_cbf('keyword',init_keywordDat)
--]]
--------------------------------------------------


--]===]
