--Author:田佰杰
--Time：2017-11-22
--开发周期：2天
--[[
开发说明：现有程序在关闭（整个程序关闭）时出现了bug：程序关闭时崩溃了。
原因：现有框架程序消息处理模块（sys/msg.lua）响应了平台消息函数（frmclose），其它程序无法响应该消息，导致程序关闭时，需要释放的对话框无法释放。
    解决方案：提供注册接口，允许其它程序收到主程序关闭的消息，从而释放各自需要释放的对话框，或者其他需要在主程序关闭时需要的操作。
--]]
local _M = {}
_G[...] = _M
package.loaded[...] = _M

local pairs = pairs
local type = type

_ENV = _M


local fs = {}  --{f=true..}

function add(f)
	if type(f)~='function' then return end
	fs[f] = true
end

function del(f)
	if type(f)~='function' then return end
	fs[f] = nil
end

function call()
	for k,v in pairs(fs) do
		if type(k) == 'function' then 
			k()
		end
	end
end



