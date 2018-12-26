
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local sysTools = TOOLS
local rpath,path = sysTools.get_path(modname)
local sysTreeFrame = require (rpath .. 'tree_frame')
local dlgAdd = require (rpath .. 'dlgs.dlg_add') 
local lfs = require 'lfs'
local execute = os.execute

local iup  = IUP
local DISK = DISK
local sysZip =ZIP

local open = io.open
local print = print
local string = string
local trace_out = trace_out

_ENV = _M


-----------------------------------------------------------------------------------------------
local function add_folder(name)
	local objTree = sysTreeFrame.get_treeObj()
	local path = objTree:get_treePath()
	local folder = path .. name 
	local mode = lfs.attributes(folder,'mode')
	if mode and mode  == 'directory' then 
		iup.Message('Warning','Folder already exist !')
		return
	end
	if not lfs.mkdir(folder) then 
		iup.Message('Warning','Failed to add folder !')
		return
	end
	-- return sysTreeFrame.add_folder(name)
	local pid = objTree:get_id()
	update_folder(pid)
	objTree:set_markedId(objTree:get_childTitleId(name,pid))
end

local function add_file(name)
	local objTree = sysTreeFrame.get_treeObj()
	local path = objTree:get_treePath()
	local file = path .. name 
	local mode = lfs.attributes(file,'mode')
	if mode and mode  == 'file' then 
		return iup.Message('Warning','File already exist !')
	end
	local f = open(file,'w+')
	if not f then 
		return iup.Message('Warning','Failed to add file !') 
	end
	f:close()
		-- return sysTreeFrame.add_file(name)
	local pid = objTree:get_id()
	update_folder(pid)
	objTree:set_markedId(objTree:get_childTitleId(name,pid))

end

function new_folder()
	local name = dlgAdd.pop()
	if not name then return end
	return add_folder(name)
end

function new_file()
	local name = dlgAdd.pop()
	if not name then return end
	if not string.match(name,'.+(%.[^%.]+)') then 
		name = name .. '.lua'
	end
	return add_file(name)
end
-----------------------------------------------------------------------------------------------
local function rename_folder(path,oldId,newName,oldName)
	local objTree = sysTreeFrame.get_treeObj()
	local folder = path .. newName 
	local mode = lfs.attributes(folder,'mode')
	if mode and mode  == 'directory' then 
		iup.Message('Warning','Failed to rename !')
		return
	end
	if not DISK.file_rename(path,oldName,newName) then 
		iup.Message('Warning','Failed to rename !')
		return
	end
	local pid = objTree:get_parentId(oldId)
	update_folder(pid)
	objTree:set_markedId(objTree:get_childTitleId(newName,pid))
end

local function rename_file(path,oldId,newName,oldName)
	local objTree = sysTreeFrame.get_treeObj()
	local file = path .. newName 
	local mode = lfs.attributes(file,'mode')
	if mode and mode  == 'file' then 
		iup.Message('Warning','Failed to rename !')
		return
	end
	if not DISK.file_rename(path,oldName,newName) then 
		iup.Message('Warning','Failed to rename !')
		return 
	end
	local pid = objTree:get_parentId(oldId)
	update_folder(pid)
	objTree:set_markedId(objTree:get_childTitleId(newName,pid))
	
end

-----------------------------------------------------------------------------------------------
--[[
function import_folder()
	local val = iup.open_dir{filetype = 'DIR'}
	if not val then return end 
	local folderName = string.match(val,'.+/([^/]+)/')
	local id = add_folder(folderName)
	if id then 
		local objTree = sysTreeFrame.get_treeObj()
		local path = objTree:get_treePath(id)
		DISK.dir_copy(val,path)
		sysTreeFrame.init_folderDat(path,id)
	end
end

function import_files()
end
--]]
-----------------------------------------------------------------------------------------------
local function get_no()
	return {
		['project/res/'] = true;
		['project/config/'] = true;
		['project/conf.lua'] = true;
		['project/main.lua'] = true;
	}
end

function rename()
	local objTree = sysTreeFrame.get_treeObj()
	local title = objTree:get_titleId()
	local path = objTree:get_treePath()
	path = string.lower(path)
	if  get_no()[path] then 
		return iup.Message('Warning','Failed to rename !')
	end
	local name = dlgAdd.pop(title)
	if not name then return end
	local upPath = objTree:get_treePath(objTree:get_parentId())
	if objTree:get_kindId() == 'BRANCH' then 
		return rename_folder(upPath,objTree:get_id(),name,title)
	else
		return rename_file(upPath,objTree:get_id(),name,title)
	end
	
end

function delete()
	
	local objTree = sysTreeFrame.get_treeObj() 
	local file = objTree:get_treePath()
	file = string.lower(file)
	if  get_no()[file] then 
		return iup.Message('Warning','Failed to delete !')
	end
	local status;
	if objTree:get_kindId() == 'BRANCH' then 
		status = DISK.dir_delete(file)
	else 
		status = DISK.file_delete(file)
	end
	if not status then iup.Message('Warning','Failed to delete !') end
	return objTree:delete_nodeId('SELECTED')
end

function open_folder()
	local objTree = sysTreeFrame.get_treeObj() 
	local file = objTree:get_treePath()
	DISK.dir_open(file)
end

function open_file()
	local objTree = sysTreeFrame.get_treeObj() 
	local file = objTree:get_treePath()
	DISK.file_open(file)
end

function update_folder(id,state)
	local objTree = sysTreeFrame.get_treeObj()
	local id = id or objTree:get_id()
	local state = state or objTree:get_stateId(id)
	local path = objTree:get_treePath(id)
	sysTreeFrame.init_folderDat(path,id)
	objTree:set_stateId(state,id)
end

------------------------------------------------------------------

function upload()
	trace_out('upload \n')
end

function download()
	trace_out('download \n')
end

function zip_to()
	local filename = 'zips/MakeApacd.zip'
	local path = 'Project/'
	sysZip.zip(filename,path)
end


function unzip_from()
	local recordProjectFile = 'config/unzip_projectRecord.lua'
	local filename = 'zips/MakeApacd.zip'
	local path = 'Project/'
	sysZip.unzip(filename,path,recordProjectFile)
	update_folder(0,'EXPANDED')
end


function unzip_toApcad()
	local recordFile = 'apcad/config/unzip_record.lua'
	local filename = 'zips/MakeApacd.zip'
	local path = 'apcad/'
	sysZip.unzip(filename,path,recordFile)
end


function unzip_toCur()
	local recordFile = 'config/unzip_record.lua'
	local filename = 'zips/MakeApacd.zip'
	local path = '.'
	sysZip.unzip(filename,path,recordFile)
	DISK.restart( 'gcad.exe')
end
