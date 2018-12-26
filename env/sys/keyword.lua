--[[
/*
*Author:Sun JinYang
*Begin:2018��08��03��
*Description:
*	����ļ����������Ѿ����õĳɷֲ������ࡣ
*Import Update Record:��Time Content��
*/
--]]
--[[
���ݽṹ��
	toolbar & menu :
		name:ֵΪstring���ͣ�����keyword��Ӧ��ʾ�����ơ�
		remark:ֵΪstring���ͣ����õı�ע��Ϣ��
		action:ֵΪfunction���ͣ��������ִ�еĺ�����
		view:ֵΪboolean���ͣ�view�����µ�����á�ȱʡֵΪtrue
		frame:ֵΪboolean���ͣ���view�����µ�����á�ȱʡֵΪtrue
		image:ֵΪstring���ͣ�ͼ������ơ�����:'a.png'
		enable:ֵΪboolean���ͻ��߷���booleanֵ��function���ͣ���ť�Ƿ���������״̬��������ûҵ�״̬����ȱʡֵΪtrue
		checkbox:ֵΪboolean���ͣ����ù�������ť�ķ����ʽΪ���º�ֱ�ӵ���ȱʡΪ���º���������
		shortcut:
		hotkey:ֵΪstrig���ͣ���Ӧ�ȼ���Ϣ
	leftDlg :
	
����keys��
	onLoad:
	onUnload;
	onAction:
	action:
	
		
ע�⣺
	����ϵͳapp�Ͳ��������ʽ��ϵͳ��app��������app����ʱ��̬��ӣ�������ڰ�װ�����������Ҫ����db�����ļ��õ���app���ص����ݲ���Ҫ�κα仯Ҳ���洢������db�ļ������������Ҫ��action��Ӧ���ַ���ת������ʵ�ĺ������д���
�ӿں�����
ʹ�÷�ʽ��
local cur = require ''.Class:new(oldTab or nil)
cur: ...
������ʽ��
	db = {
		key1 = {action = '',name =,view =,...};
		key2 = {action = '',name =,view =,...};
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



init_keywordDat =  function(dat)
	keywordDat  = keywordDat or {}
	db = sysTools.deepcopy(dat)
	for k,keyDat in pairs(db) do 
		keywordDat[k] = {}
		setmetatable(keywordDat[k],
			{
				__index = function(tab,key)
					local cur = keyDat[key]
					if not cur then return end 
					if type(cur) == 'table' and cur.type == 'function' then 	
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

