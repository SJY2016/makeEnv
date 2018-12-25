--[[
/*
*Author:Sun JinYang
*Begin:2018年07月03日
*Description:
*	本文件实现通用的api函数
*Import Update Record:（Time Content）
*/
--]]
--[[
数据结构：
接口函数：
	get_path(modname)
		return:
			rpath:当前文件所在文件夹的加载路径。例如：'app.greenmark.'
			path:当前文件所在文件夹路径。例如：'app/greenmark/'
	require = get_lowerRequire()
		require 文件时将文件路径全部小写。
	hash_string(str)
		计算字符串的hash值。
		return ：string
	hash_file(file)
		计算文件的hash值。
		return ：string
	get_guid()
		创建global id。
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local luaext = require 'luaext'
local crypto = require"crypto"
local sysDisk = require 'sys.disk'

local lower = string.lower
local match = string.match
local gsub = string.gsub
local assert = assert
local type = type
local print = print
local require = require
local string = string
local pairs = pairs

_ENV = _M

--modname 参数值分两种情况针对同一个文件app/greenmark/element/element.lua
--正常情况: app.greenmark.element.element
--模型加载：app/greenmark/element/element
function get_path(modname)
	
	assert(type(modname) == 'string')
	-- print(modname)
	modname = gsub(modname,'/','.')
	modname = gsub(modname,'\\','.')
	local rpath = lower(match(modname,'(.+%.)[^%.]+'))
	local path = gsub(rpath,'%.','/')
	return rpath,path
end

function get_upRpath(rpath)
	return string.match(rpath,'(.+%.)[^%.]+%.')
end


function get_lowerRequire()
	return function(str)
		return require (lower(str))
	end
end

function hash_string(str)
	local dig = crypto.digest;
	if not dig then return nil end
	local d = dig.new("sha1");
	local s = d:final(str);
	d:reset();
	return s;
end

function hash_file(file)
	if type(file)~='string' then return end
	local str = sysDisk.file_read(file,true)
	if not str or str == '' then return '0kb' end 
	return hash_string(str);
end

function get_guid()
	return luaext.guid()
end

function deepcopy(tab,newTab)
	if type(tab) ~= 'table' then return {} end 
	local newTab = newTab or {}
	for k,v in pairs(tab) do 
		if type(v) ~= 'table' then 
			newTab[k] = v
		else 
			newTab[k] = {}
			deepcopy(v,newTab[k])
		end
	end
	return newTab
end
