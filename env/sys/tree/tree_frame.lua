
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = require 'sys.tools'
local rpath,path = sysTools.get_path(modname)
local upRpath =sysTools.get_upRpath(rpath)

local rmenu = require (rpath .. 'tree_rmenu')
local action = require (rpath .. 'tree_action')
local classTree = require (upRpath .. 'iup.tree').Class
local sysDisk = require 'sys.disk'
local lfs = require 'lfs'

local iup = iup
local pairs = pairs
local ipairs = ipairs
local print =print
local type = type
local table = table
local string = string

_ENV = _M

local file = 'config/tree/style.lua';

local function get_treeStyle()
	local tree =sysDisk.file_read(file) or  {}
	-- tree.expand = 'YES'
	return tree
end

function on_dlbtn()
	print('on_dltbn')
	if get_treeObj():get_kindId(id) == 'LEAF' then 
		action.open_file()
	end
end

function on_lbtn()
	print('on_ltbn')
end

function deal_resImage(id)
	local objTree = get_treeObj()
	local id  = id or objTree:get_id()
	local file = objTree:get_treePath(id)
	return iup.LoadImage(file)
end

function on_rbtn()
	local objTree = get_treeObj()
	local id = objTree:get_id()
	if id == 0 then 
		return rmenu.get_rootRmenu()
	elseif objTree:get_kindId(id) == 'BRANCH' then 
		return rmenu.get_folderRmenu()
	elseif objTree:get_kindId(id) == 'LEAF' then 
		return rmenu.get_leafRmenu()
	end
end

local function init_obj()
	local objTree;
	
	local function init()
		objTree = classTree:new(get_treeStyle())
		return objTree
	end
	return function()
		return objTree or init()
	end,function()
		return objTree and objTree:get_control() or init():get_control()
	end,function()
		return iup.frame{objTree and objTree:get_control() or init():get_control(),tabtitle = 'Browser'}
	end
end

get_treeObj,get_control,get_frame = init_obj()

function turn_treeDat(dat,lev,newTab)
	local newTab = newTab or {}	
	local folderTab,fileTab = {},{};
	for k,v in ipairs(dat) do 
		if type(v) == 'table' then 
			folderTab[#folderTab+1] = v
		else 
			fileTab[#fileTab+1] = v
		end
	end
	table.sort(folderTab,function(a,b) return string.lower(a.name) < string.lower(b.name) end)
	table.sort(fileTab,function(a,b) return string.lower(a) < string.lower(b) end)
	
	for k,v in ipairs(folderTab) do 
		newTab[#newTab+1] = {attributes = {title = v.name},{}}
		if lev  == 0 and v.name == 'res' then 
			newTab[#newTab][1].attributes = {image = deal_resImage}
		end
		turn_treeDat(v,lev + 1,newTab[#newTab][1])
	end
	for k,v in ipairs(fileTab) do 
		newTab[#newTab+1] = {attributes = {title = v}}
	end
	return newTab
end

function init_dat()
	local dat = get_treeStyle()
	get_treeObj():init_tree_data(dat)
	local dat = sysDisk.read_dir('Project/',true)
	local lev = 0
	dat = turn_treeDat(dat,lev)
	get_treeObj():init_node_data(dat,0)
end

function init_folderDat(path,id)
	local id = id or get_treeObj():get_id()
	local dat = sysDisk.read_dir(path,true)
	dat = turn_treeDat(dat,id == 0 and 0 or 1)
	get_treeObj():init_node_data(dat,id)
end

local function get_addPos(name,addType)
	local objTree = get_treeObj()
	local id = id or objTree:get_id()
	local count = objTree:get_childCountId(id)
	local curId = id +1
	local last;
	for i = 1,count do 
		local title = objTree:get_titleId(curId)
		local kind = objTree:get_kindId(curId)
		if kind == addType then 
			if string.lower(title) > string.lower(name) then 
				if last then 
					return last.id
				else
					return id
				end
			end
		end
		last = {title = title,kind = objTree:get_kindId(curId),id = curId}
		curId = curId + 1 + objTree:get_totalChildCountId(curId)
	end
	return last and last.id or id --文件夹内没有内容时 返回id
	-- return objTree:insert_branchId(name,last.id)
end

-- function add_folder(name)
	-- local objTree = get_treeObj()
	-- local id = objTree:get_id()
	-- local lastId =  get_addPos(name,'BRANCH')
	-- local newId;
	-- if id == lastId then 
		-- newId = objTree:add_branchId(name,lastId)
	-- else 
		-- newId = objTree:insert_branchId(name,lastId)
	-- end
	-- objTree:set_markedId(newId)
	-- return newId
-- end

-- function add_file(name)
	-- local objTree = get_treeObj()
	-- local id = objTree:get_id()
	-- local lastId =  get_addPos(name,'LEAF')
	-- local newId;
	-- if id == lastId then 
		-- newId = objTree:add_leafId(name,lastId)
	-- else 
		-- newId =  objTree:insert_leafId(name,lastId)
	-- end
	-- objTree:set_markedId(newId)
	-- objTree:update_nodeStyle(newId)
-- end





