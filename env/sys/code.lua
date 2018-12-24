
local modname = ...
local M = {}
_G[modname] = M
package.loaded[modname] = M


local string = string
local io = io
local pairs = pairs
local type = type
local tostring = tostring
local concat = table.concat
local getmetatable = getmetatable
local setmetatable = setmetatable
local table = table
local print = print
local ipairs = ipairs

_ENV = M

local sort_;
local cur_;

local function init(sort,cur)
	sort_ = sort
	cur_ = cur
end

function strout(rs)
	return function(str)
		rs[#rs+1] = str
	end
end

function io_out(file)
	return function(str)
		file:write(str)
	end
end

function is_met(tab)
	return function(t)
		tab[#tab+1] = t
	end
end

function basicSerialize(o,saved)
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "table" then
		return saved[o]
	elseif type(o) == "boolean" then
		return tostring(o)
	else
		return string.format("%q",o)
	end
end

local function sort_table(name,value,out,saved)
	local tempt = {}
	for k,v in pairs(value) do 
		if k ~= '__index' then
			if type(k) == 'string' or type(k) == 'number' then 
				tempt[#tempt + 1] = k
			end
		end
	end
	table.sort(tempt,function(a,b) return tostring(a) < tostring(b) end )
	for k,v in ipairs(tempt) do
		k = basicSerialize(v,saved)
		if k then 
			local fname =  string.format("%s[%s]",name,k)
			save_process(fname,value[v],out,saved)
		end
	end
end

local function normal_table(name,value,out,saved)
	for k,v in pairs(value) do
		if k ~= '__index' then
			if type(k) == 'string' or type(k) == 'number' then 
				k = basicSerialize(k,saved)
				if k then 
					local fname =  string.format("%s[%s]",name,k)
					save_process(fname,v,out,saved)
				end
			end
		end
	end
end

local function get_metatable(dat,out)
	saved = saved or {}
	local metatable = getmetatable(dat)
	if metatable then 
		get_metatable(metatable,out)
	end
	out(dat)
end

function op_table(name,value,out,saved)
	if saved[value] then 
		out(saved[value] .. '\n')
	else
		saved[value] = name
		out ("{}\n")
		if cur_ then 
			if sort_ then 
				sort_table(name,value,out,saved)
			else 
				normal_table(name,value,out,saved)
			end
		else 
			local res = {}
			get_metatable(value,is_met(res))
			for k,v in ipairs (res) do
				if sort_ then 
					sort_table(name,v,out,saved)
				else 
					normal_table(name,v,out,saved)
				end
			end
		end
	end
end

function save_process(name,value,out,saved)
	if not name then return end 
	saved = saved or {}
	if type(value) == "number" or type(value) == "string" or type(value) =="boolean" then
		out(name .. " = ")
		out(basicSerialize(value) .. "\n")
	elseif type(value) == "table" then
		out(name .. " = ")
		op_table(name,value,out,saved)
	elseif type(value) == "function" then
	--	out("function()   end \n")
	elseif type(value) == "nil" then
	--	out("nil\n")
	else
	--	out("nil\n")
	end
	
end



local function save_(key,content,out,t)
	if key then
		save_process(key,content,out)
	else
		for k,v in pairs(content) do
			save_process(k,v,out,t)
		end
	end
end


function save_io(file,content,key)
	local f = io.open(file,"w")
	local t = {}
	local out = io_out(f)
	save_(key,content,out,t)
	f:close()
end

function save_str(content,key)
	local rs = {}
	local t = {}
	local out = strout(rs)
	save_(key,content,out,t)
	return concat(rs) 
end


--arg = {file,data,--key,--returnKey,--sort,--current }
function save(arg)
	arg = arg or {}
	local file = arg.file
	local dat = arg.data
	local key = arg.key or 'db'
	local isReturn = arg.returnKey
	local cur = arg.current
	if not file or not dat then return end 
	init(arg.sort,arg.current )
	local f = io.open(file,"w")
	local t = {}
	local out = io_out(f)
	save_(key,dat,out,t)
	if isReturn then 
		out('return ' .. key)
	end
	f:close()
end



function save_sort(arg)
	arg = arg or {}
	local file = arg.file
	local dat = arg.data
	local key = arg.key or 'db'
	local isReturn = arg.returnKey
	local cur = arg.current
	if not file or not dat then return end 
	init(true,arg.current )
	local f = io.open(file,"w")
	local t = {}
	local out = io_out(f)
	save_(key,dat,out,t)
	if isReturn then 
		out('return ' .. key)
	end
	f:close()
end


function serialize_all(arg)
	arg = arg or {}
	local file = arg.file
	local dat = arg.data
	local key = arg.key or 'db'
	local isReturn = arg.returnKey
	local cur = arg.current
	if not dat then return end 
	init(arg.sort,arg.current )
	local rs = {}
	local t = {}
	local out = strout(rs)
	save_(key,dat,out,t)
	if isReturn then 
		out('return ' .. key)
	end
	return concat(rs) 
end


function copy(obj,seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({},getmetatable(obj))
	s[obj] = res
	for k,v in pairs(obj) do
		res[copy(k,s)] = copy(v,s)
	end
	return res
end

---------------------------------------
--[==[
local io = io
local tostring = tostring
local type = type
local string = string
local pairs = pairs
local error = error
local table = table
local ipairs = ipairs
local getmetatable = getmetatable
local setmetatable = setmetatable
local rawget = rawget

local M = {}
local modname = ...
_G[modname] = M
package.loaded[modname] = M
_ENV = M

local function basicSerialize(o,saved)
	if type(o) == "number" then
		return tostring(o)
	elseif type(o) == "table" then
		return saved[o]
	elseif type(o) == "boolean" then
		return tostring(o)
	else
		return string.format("%q",o)
	end
end

local function lua_save(name,value,saved)
	if not name then return end
	io.write(name,' = ')
	if type(value) == "number" or type(value) == "string" or type(value) =="boolean" then
		io.write(basicSerialize(value),"\n")	
	elseif type(value) == "table" then
		saved = saved or {}
		if saved[value] then
			io.write(saved[value],"\n")
		else
			saved[value] = name
			io.write("{}\n")
			for k,v in pairs(value) do
				k = basicSerialize(k,saved)
				if k then 
					local fname =  string.format("%s[%s]",name,k)
					lua_save(fname,v,saved)
				end
			end
		end
	-- else
		-- error("cannot save a "..type(value))
	end
end

local function save_table(file,content,key,returnKey)
	local temp = io.output()
	io.output(file)
	local t = {}
	local key = key or 'db'
	if type(content) == 'table' then 
		lua_save( key,{},t)
		for k,v in pairs(content) do
			if type(k) == "number" then 
				lua_save(key .. "[" .. k .. "]",v,t)
			else
				lua_save(key .. "[" .. string.format('%q',k) .. "]",v,t)
			end
		end
		if returnKey  then 
			io.write('return ',key)
		end 
	else 
		if type(content) == "number" or type(content) == "string" or type(content) =="boolean" then
			io.write(basicSerialize(content),"\n")	
		end
	end
	io.flush()
	io.output():close()
	io.output(temp)
end

--arg = {file,data,--key,--returnKey,--sort,--current }
function save(arg)
	arg = arg or {}
	if not arg.file or not arg.data then return end 
	if arg.sort then 
		save_sort(arg)
	else 
		save_table(arg.file,arg.data,arg.key,arg.returnKey)
	end
end

function save_sort(arg)
	if type(arg) ~= 'table' then return end 
	if not arg.data or not arg.file then return end 
	if arg.current then 
		serialize(arg,true)
	else 
		serialize_all(arg,true)
	end
end

local function save_t(arg,tab)
	local file = arg.file
	local temp = io.output()
	io.output(file)
	for k,v in ipairs(tab) do 
		--io.write(string.format('%q',v))
		io.write(v)
	end
	io.flush()
	io.output():close()
	io.output(temp)
end

--arg = {key,data,returnKey}
function serialize(arg,isSave) --不会序列化元表的内容（如果有元表）
	if type(arg) ~= 'table' then return end 
	if not arg.data then return end 
	
	function serialize_to_str(data,key,t,state)
		local t = t or {};
		local curkey = key or 'db'
		
		local tempt = {}
		for k,v in pairs(data) do 
			if type(k) == 'number' or type(k) == 'string'  then 
				table.insert(tempt,k)
			end
		end
		table.sort(tempt,function(a,b) return tostring(a) < tostring(b) end )
		
		for k,key in ipairs (tempt) do 
			if type(key) == 'number' then 
				str = curkey .. '[' .. key .. ']'
			elseif type(key) == 'string' then 
				str = curkey .. '[' .. string.format('%q',key) .. ']'
			end
			local v =data[key]
			if type(v) == 'table' then 
				table.insert(t,str .. ' = {};\n')
				serialize_to_str(v,str,t,true)
			elseif type(v) == 'string' then 	
				--table.insert(t, str .. ' = \'' .. v .. '\';\n')
				table.insert(t, str .. ' = ' .. string.format('%q',v) .. ';\n')
			elseif type(v) == 'number' or type(v) == 'boolean' then 
				table.insert(t,str .. ' = ' .. tostring(v).. ';\n')
			end
		end
		if not state  then 
			table.insert(t,1,curkey .. ' = {};\n')
			if arg.returnKey then 
				table.insert(t,'return ' .. curkey)
			end
			if isSave then 
				save_t(arg,t)
			end
			return table.concat(t,'')
		end
	end

	return serialize_to_str(arg.data,arg.key)
end

--arg = {key,data,returnKey}
function serialize_all(arg,isSave) --会序列化元表中的内容（如果有元表）
	if type(arg) ~= 'table' then return end 
	if not arg.data then return end 
	local t = {}
	local serialize_met;
	local function serialize_to_str(data,key,t)
		local t = t or {};
		local curkey = key or 'db'
		local tempt = {}
		for k,v in pairs(data) do 
			if rawget(data,k) and k ~= '__index' then 
				if type(k) == 'number' or type(k) == 'string'  then 
					table.insert(tempt,k)
				end
			end
		end
		table.sort(tempt,function(a,b) return tostring(a) < tostring(b) end )
		
		for k,key in ipairs (tempt) do 
			if type(key) == 'number' then 
				str = curkey .. '[' .. key .. ']'
			elseif type(key) == 'string' then 
				str = curkey .. '[' .. string.format('%q',key) .. ']'
			end
			local v =rawget(data,key)
			if type(v) == 'table' then 
				table.insert(t,str .. ' = {};\n')
				-- 
				local met = getmetatable(v);
				if met then 
					serialize_met(v,str,t)
				else 	
					serialize_to_str(v,str,t)
				end
			elseif type(v) == 'string' then 	
				table.insert(t, str .. ' = ' .. string.format('%q',v) .. ';\n')
			elseif type(v) == 'number' or type(v) == 'boolean' then 
				table.insert(t,str .. ' = ' .. tostring(v).. ';\n')
			end
		end
	end
	
	function serialize_met(src,key,t)
		local met = getmetatable(src);
		
		if met then
			serialize_met(met,key,t);
		end
		serialize_to_str(src,key,t)	
	end
	
	local curkey = arg.key or 'db'
	serialize_met(arg.data,curkey,t)
	table.insert(t,1,curkey .. ' = {};\n')
	if arg.returnKey then 
		table.insert(t,'return ' .. curkey)
	end
	if isSave then
		save_t(arg,t)
	end
	return table.concat(t,'')
end
--]==]
----------------------------------------------------------------
--test data 

