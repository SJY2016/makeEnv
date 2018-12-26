
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local rpath,path = TOOLS.get_path(modname)
local classLang = LANG.Class
local action = require (rpath .. 'tree_action')

local ipairs = ipairs
local type = type

_ENV = _M


local itemNewFolder = {langKey = 'New Directory'}
local itemImportFolder = {langKey = 'Import Directory'}
local itemNewFile = {langKey = 'New File'}
local itemImportFiles = {langKey = 'Import Files'}
local itemRename = {langKey = 'Rename'}
local itemDelete = {langKey = 'Delete'}
local itemOpenFolder = {langKey = 'Open Directory'}
local itemOpenFile = {langKey = 'Open File'}
local itemUpdateFolder = {langKey = 'Refresh Directory'}

local itemUpload = {langKey = 'UpLoad'}
local itemDownload = {langKey = 'DownLoad'}
local itemZipTo ={langKey = 'Zip To'}
local itemUnzip = {langKey = 'Unzip to project'}
local itemUnzipToCur = {langKey = 'Unzip to cur'}
local itemUnzipToApcad = {langKey = 'Unzip to apcad'}
---------------------------------------------------------------------------------------------

local function init_rmenu(items)
	local record;
	return function()
		local lang = classLang:new('sys/tree/tree_rmenu')
		local lan = lang:get_ver()
		if lan ==  record or not items then lang:close() return end 
		record = lan
		for k,v in ipairs(items) do 
			if type(v) == 'table' then 
				v.title =lang:get_id_name(v.langKey ) or v.langKey
			end
		end
		lang:close()
	end
end
---------------------------------------------------------------------------------------------

local rootRmenu = {
	itemNewFolder;
	itemNewFile;
	'';
	itemOpenFolder;
	itemUpdateFolder;
	'';
	itemUpload;
	itemDownload;
	'';
	itemZipTo;
	itemUnzip;
	'';
	itemUnzipToCur;
	itemUnzipToApcad;
}

local folderRmenu = {
	itemNewFolder;
	-- itemImportFolder;
	itemNewFile;
	-- itemImportFiles;
	'';
	itemRename;
	itemDelete;
	'';
	itemOpenFolder;
	itemUpdateFolder;
	'';
	itemUpload;
	itemDownload;
}

local fileRmenu = {
	itemRename;
	itemDelete;
	'';
	itemOpenFile;
	'';
	itemUpload;
	itemDownload;
}

local init_rootRmenu = init_rmenu(rootRmenu)
local init_folderRmenu = init_rmenu(folderRmenu)
local init_fileRmenu = init_rmenu(fileRmenu)

---------------------------------------------------------------------------------------------

function get_rootRmenu()
	init_rootRmenu()
	return  rootRmenu
end

function get_folderRmenu()
	init_folderRmenu()
	return  folderRmenu
end

function get_leafRmenu()
	init_fileRmenu()
	return  fileRmenu
end
---------------------------------------------------------------------------------------------
itemNewFolder.action = function() action.new_folder() end
itemNewFile.action = function() action.new_file() end
itemRename.action = function() action.rename() end
itemDelete.action = function() action.delete() end
itemOpenFolder.action = function() action.open_folder() end
itemOpenFile.action = function() action.open_file() end
itemUpdateFolder.action = function() action.update_folder() end
itemUpload.action = function() action.upload() end
itemDownload.action = function() action.download() end
itemZipTo.action = function() action.zip_to() end
itemUnzip.action = function() action.unzip_from() end
itemUnzipToApcad.action = function() action.unzip_toApcad() end
itemUnzipToCur.action = function() action.unzip_toCur() end
--[[
itemImportFolder.action = function() action.import_folder() end
itemImportFiles.action = function() action.import_files() end
--]]
