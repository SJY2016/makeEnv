--[==[
	zip原生函数整理：
	zip.OR(flag1[, flag2[, flag3 ...]])  --并集处理参数方法，可以利用此函数附带多个控制参数
	zip_arc = zip.open(filename [, flags])
	zip.open(filename,zip.OR(zip.CREATE ,zip.EXCL)) --文件打开，返回值是打开的句柄类似与lua 中io.open函数
	参数：
		zip.CREATE --没有则创建
		zip.EXCL  --如果有报错
		zip.CHECKCONS --检查一致性?
	zip_arc:get_num_files() or #zip_arc --获取压缩文件中文件的个数
	
	zip_arc:name_locate(filename [, flags]) --在压缩文件中定位文件，返回值是一个索引id。
	参数：
		zip.FL_NOCASE --忽略大小写
		zip.FL_NODIR --查找时忽略在压缩文件中的路径部分。（在压缩文件中可能有多个路径下包含同一个文件名的文件，有可能在找到一个后就不在继续查找？）
		
	local file =zip_arc:open(filename | file_idx [, flags]) --open的open。
	--通过文件名或者文件索引打开zip包中的某个文件。返回值是一个打开文件的句柄。
	参数：
		zip.FL_COMPRESSED --读取压缩文件中该文件压缩的数据。可以通过file:read().来读取压缩前的数据。
		zip.FL_UNCHANGED
		--读取压缩文件中最原始的数据，忽略掉任何此文件的变化。
		zip.FL_NOCASE --忽略大小写
        zip.FL_NODIR --忽略路径。
		FL_NOCASE和FL_NODIR应该是为了查找到该文件，如果利用索引值应该不需要这两个参数。毕竟在压缩文件中各个文件的索引值唯一。
	注意：	
		这个文件的句柄仅仅被用于文件的读操作。
	file:close() --有打开就需要关闭
	local str = file:read(num)  --读取文件中最多num个字符。
	local stat = zip_arc:stat(filename | file_idx [, flags])
	--获得指定文件或者文件索引的信息。
	--参数：	
		zip.FL_UNCHANGED
		zip.FL_NOCASE
		zip.FL_NODIR
	返回值是一个关于此文件状态的状态表：
		stat.name              = name of the file --文件名
        stat.index             = index within archive --文件在压缩包中的索引id
        stat.crc               = crc of file data --文件数据的crc校验
        stat.size              = size of file (uncompressed) --文件大小（未压缩的）
        stat.mtime             = modification time --文件的修改时间
        stat.comp_size         = size of file (compressed) --文件压缩的大小
        stat.comp_method       = compression method used --文件压缩使用的方法
        stat.encryption_method = encryption method used --压缩文件使用加密的方法
	如果有错误会返回nil加上错误信息。
	
	local filename = zip_arc:get_name(file_idx [, flags])
	--返回指定索引的文件名
	--唯一有效的参数
		zip.FL_UNCHANGED
		
	local comment = zip_arc:get_archive_comment([flags])
	--返回压缩文件中包含的注释。
	--唯一有效的参数
		zip.FL_UNCHANGED
	zip_arc:set_archive_comment(comment)
	--设置压缩文件中包含的注释。注释的内容超过65,535 bytes可能会报错。
	local comment = zip_arc:get_file_comment(file_idx [, flags])
	--返回压缩文件中指定文件包含的注释。
	--唯一有效的参数
		zip.FL_UNCHANGED
	zip_arc:set_file_comment(file_idx, comment)
	--设置压缩文件中指定文件包含的注释。输入无效会报错。
	zip_arc:add_dir(dirname)
	--创建一个新目录。如果创建的目录名是一个已经存在的或者输入的值是无效的可能会抛出错误。
	file_idx = zip_arc:add(filename, ...zip_source)
	--向压缩文件中添加文件。有错误就抛出错误
	file_idx = zip_arc:replace(file_idx, ...zip_source)
	--用新的文件替换在压缩文件指定的文件。
	zip_arc:rename(filename | file_idx, new_filename)
	--重命名一个在压缩文件中指定的文件。如果视图被重命名的文件不存在的话则会抛出错误。
	zip_arc:delete(filename | file_idx)
	--删除压缩文件中指定的文件。文件不存在抛出错误。
	..zip_source = "string", str
	--资源来自于指定的字符串。
	...zip_source = "zip", other_zip_arc, file_idx[, flags[, start[, len]]])
	--资源来自于其他压缩包。
	--示例：ar1:add("filename.txt", "zip", ar2, 1)，后面的参数是可选的。
			zip.FL_UNCHANGED
			zip.FL_RECOMPRESS --这个‘flag’控制的是在压缩文件中当前设置替换原来压缩文件中的设置。
		注意：循环引用不可以比如，将a 中1文件加入到b中2文件，在从b中的2文件加入a中1文件是不可取的。
	...zip_source = "file", filename[, start[, len]]	 
	--资源来自于本地磁盘文件。
	
--]==]
--[==[
	zip 包来源于 luazip.dll
	说明如下：
	**********************************************************************
* Author  : Brian Maher <maherb at brimworks dot com>
* Library : lua_zip - Lua 5.1 interface to libzip
*
* The MIT License
* 
* Copyright (c) 2009 Brian Maher
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
**********************************************************************

To use this library, you need libzip, get it here:
     http://www.nih.at/libzip/

To build this library, you need CMake, get it here:
    http://www.cmake.org/cmake/resources/software.html

Loading the library:

    If you built the library as a loadable package
        [local] zip = require 'brimworks.zip'

    If you compiled the package statically into your application, call
    the function "luaopen_brimworks_zip(L)". It will create a table
    with the zip functions and leave it on the stack.

Note:

    There is not a "streaming" interface supplied by this library.  If
    you want to work with zip files as streams, please see
    lua-archive.  However, libarchive is currently not compatible with
    "office open xml", and therefore the author was motivated to write
    this zip specific binding.

Why brimworks prefix?

    When this module was created, there was already a binding to
    zziplib named "zip" and since the author owns the brimworks.com
    domain he felt prefixing with brimworks would avoid in collisions
    in case people need to use the zziplib binding at the same time.

-- zip functions --

zip.CREATE
zip.EXCL
zip.CHECKCONS

    Numbers that represent open "flags", see zip.open(). --打开文件处理标志

zip.FL_NOCASE
zip.FL_NODIR

    Numbers that represent locate "flags", see zip_arc:name_locate().--文件定位标志

zip.FL_COMPRESSED
zip.FL_UNCHANGED

    Numbers that represent fopen "flags", see zip_arc:open().--文件流打开

flags = zip.OR(flag1[, flag2[, flag3 ...]]) 

    Perform a bitwise or on all the flags. --允许一个或多个状态存在

local zip_arc = zip.open(filename [, flags])

    Open a zip archive optionally specifying a bitwise or of any of
    these flags:--打开一个zip文件，可以使用下面的参数
		
        zip.CREATE
            Create the archive if it does not exist.
			--如果归档文件不存在则创建归档（压缩文件）
        zip.EXCL
            Error if archive already exists.
			--这个参数可以控制如果归档文件已经存在则会引发一个error
        zip.CHECKCONS
            Perform additional consistency checks on the archive, and
            error if they fail.
			--这个参数可以控制一致性检查？
    If an error occurs, returns nil plus an error message.
		--产生的错误时，会返回nil值加上一个错误信息。

zip_arc:close()

    If any files within were changed, those changes are written to
    disk first. If writing changes fails, zip_arc:close() fails and
    archive is left unchanged. If archive contains no files, the file
    is completely removed (no empty archive is written). 
	--译文：如果任何文件在内部被改变。这些改变首先会被写入磁盘，如果写入改变失败，不会破坏原有的zip文件。如果zip包中没有任何文件，这个zip文件会被删掉（不存在空的zip）

    Unlike the other functions, this function will "throw" an error if
    there is any failure.  The reason to be different is that it is
    easy to forget to check if close is successful, and a failure to
    close is truely an exceptional event.
--译文：
	close 函数不像其它函数。这个函数如果有任何失败的行为都会扔出错误。不同的原因是如果关闭成功则会忽略检查，如果失败则会按照特殊的时间处理结束。

    NOTE: If a zip_arc object is garbage collected without having
    called close(), then the memory associated with that object will
    be free'ed, but changes made to the archive are not committed.
--译文：
	注意：
	如果一个zip归档文件在没有调用close函数情况下被当做垃圾收集了，然后与此对象相关的内存就会被释放，但是处理过得关于此zip文件的任何变化都不会被提交（任何之前的操作都将没有意义）。
local last_file_idx = zip_arc:get_num_files()
local last_file_idx = #zip_arc

    Return the number of files in this zip archive, and since the
    index is one based, it also is the last file index.
--译文：
	返回zip压缩文件中文件的个数。，并且返回的值即代表了文件的个数，也代表zip文件中最后一个文件的索引。
local file_idx = zip_arc:name_locate(filename [, flags])
	--功能：在zip压缩文件中查找已知文件名的文件，返回值是该文件在压缩文件中的索引id，如果没有找到则返回nil 和一个错误信息。
    Returns the 1 based index for this file.  The flags argument may
    be a bitwise or of these flags:

        zip.FL_NOCASE--忽略大小写
            Ignore case distinctions. 

        zip.FL_NODIR--忽略zip文件中包含路径的文件。
            Ignore directory part of file name in archive.

    If it is not found, it returns nil plus an error message.

local file = zip_arc:open(filename | file_idx [, flags])
	--通过文件名或者文件索引打开zip包中的某个文件。返回值是一个打开文件的句柄。
    Returns a new file handle for the specified filename or file
    index.  The flags argument may be a bitwise or of these flags:

        zip.FL_COMPRESSED
            Read the compressed data. Otherwise the data is
            uncompressed by file:read().
--读取压缩文件中该文件压缩的数据。可以通过file:read().来读取压缩前的数据。
        zip.FL_UNCHANGED
            Read the original data from the zip archive, ignoring any
            changes made to the file.
		--读取压缩文件中最原始的数据，忽略掉任何此文件的变化。
        zip.FL_NOCASE
        zip.FL_NODIR
            See zip_arc:name_locate().

    Note that this file handle can only be used for reading purposes.
	--这个文件的句柄仅仅被用于文件的读操作。
	
file:close()

    Close a file handle opened by zip_arc:open()

local str = file:read(num)
	--读取文件中最多num个字符。
    Read at most num characters from the file handle.

local stat = zip_arc:stat(filename | file_idx [, flags])
	--获得指定文件或者文件索引的信息。
    Obtain information about the specified filename or file index.
    The flags may be a bitwise or of these flags:

        zip.FL_UNCHANGED
            See zip_arc:open().

        zip.FL_NOCASE
        zip.FL_NODIR
            See zip_arc:name_locate().

    The returned stat table contains the following fields:

        stat.name              = name of the file
        stat.index             = index within archive
        stat.crc               = crc of file data
        stat.size              = size of file (uncompressed)
        stat.mtime             = modification time
        stat.comp_size         = size of file (compressed)
        stat.comp_method       = compression method used
        stat.encryption_method = encryption method used

    If an error occurs, this function returns nil and an error
    message.

local filename = zip_arc:get_name(file_idx [, flags])

    Returns the name of the file at the specified file index.  The
    only valid flag is:

        zip.FL_UNCHANGED
            See zip_arc:open().

local comment = zip_arc:get_archive_comment([flags])

    Return any comment contained in the archive.  The only valid flag
    is:

        zip.FL_UNCHANGED
            See zip_arc:open().

zip_arc:set_archive_comment(comment)

    Sets the comment of an archive.  May throw an error if the comment
    exceeds 65,535 bytes.

local comment = zip_arc:get_file_comment(file_idx [, flags])

    Return any comment about the specified file.  The only valid flag
    is:

        zip.FL_UNCHANGED
            See zip_arc:open().

zip_arc:set_file_comment(file_idx, comment)

    Set the comment for a specified file index within the archive.
    Throws an error if input is invalid.

zip_arc:add_dir(dirname)

    Creates a new directory within the archive.  May throw an error if
    an entry already exists in the archive with that name or input is
    invalid.

file_idx = zip_arc:add(filename, ...zip_source)

    Adds the specified filename to the archive from the specified
    "...zip_source" (see below).

    If an error occurs, throws an error.

file_idx = zip_arc:replace(file_idx, ...zip_source)

    Replaces the specified file index with a new "...zip_source"
    (see below).

    If an error occurs, throws an error.

zip_arc:rename(filename | file_idx, new_filename)

    Rename the specified file in the archive.  May throw an error if
    the entry being renamed does not exist.

zip_arc:delete(filename | file_idx)

    Delete the specified file from the archive.  May throw an error if
    the specified filename or file index does not exist.

..zip_source = "string", str

    The source to use will come from the specified string.

...zip_source = "zip", other_zip_arc, file_idx[, flags[, start[, len]]])

    The "...zip_source" is an archive and file index into that archive
    along with an optional flag, start file offset and length.  The
    flags are an optional bitwise or of:

        zip.FL_UNCHANGED
            See zip_arc:open().

        zip.FL_RECOMPRESS
            When adding the data from srcarchive, re-compress it using
            the current settings instead of copying the compressed
            data.

    Circular zip source references are not allowed.  For example, if
    you add a file from ar2 into ar1, then you can't add a file from
    ar1 to ar2.  Here is an example of this error:

        ar1:add("filename.txt", "zip", ar2, 1)
        ar2:add("filename.txt", "zip", ar1, 1) -- ERROR!


...zip_source = "file", filename[, start[, len]]

    Create a "zip_source" from a file on disk.  Opens filename and
    reads len bytes from offset start from it. If len is 0 or -1, the
    whole file (starting from start) is used.

######################################################################
TODO: The following functions are not implemented yet:
######################################################################

...zip_source = "object", obj

    The "...zip_source" is an object with any of these methods:

        success = obj:open()
            Prepare for reading. Return true on success, nil on
            error.

        str = obj:read(len)
            Read len bytes, returning it as a string.  Return nil on
            error.

        obj:close()
            Reading is done.

        stat = obj:stat()
            Get meta information for the input data.  See
            zip_arc:stat() for the table of fields that may be set.
            Usually, for uncompressed data, only the mtime and size
            fields will need to be set.

        libzip_err, system_err = obj:error()
            Get error information.  Must return two integers whic
            correspond to the libzip error code and system error code
            for any error (see above functions that may cause errors)
===============================================================================================
详解：
	zip.CREATE 创建目标压缩文件（如果目标压缩文件不存在的情况下，有则不创建）
	zip.EXCL 这个参数可用来控制判断压缩文件是否已经存在，已经存在的话会引发一个错误。
--]==]

local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local luazip = require"luazip"
local lfs = require 'lfs'
local sysDisk = require 'sys.disk'

local next = next
local remove = os.remove
local print = print
local string = string
local trace_out = trace_out
local type = type
local assert = assert
local rename = os.rename
local open = io.open

_ENV = _M

local CurOpenZip;
-----------------------------------------------------------------
function table_is_empty(t)
	return next(t) == nil
end

function delete(filename)
	remove(filename)
end 

function get()
	return CurOpenZip
end

function create(zipfile)
	close()
	CurOpenZip =  luazip.open(zipfile,luazip.CREATE) 
	return CurOpenZip
end

function close()
	if CurOpenZip then CurOpenZip:close() CurOpenZip= nil end
end

function add_folder(file)
	if CurOpenZip then CurOpenZip:add_dir(file) end
end

--arg = {file,mode,src}
function add(arg)
	local file,mode,src = arg.file,arg.mode,arg.src
	if CurOpenZip then 
		local file_idx = CurOpenZip:name_locate(file,luazip.FL_NOCASE)
		if file_idx then CurOpenZip:replace(file_idx,mode,src) 
			return 
		end
		CurOpenZip:add(file,mode,src)
	end
end

function delete(fileInZip)
	if not CurOpenZip then return end 
	local file_idx = CurOpenZip:name_locate(fileInZip)
	if not file_idx then return end
	CurOpenZip:delete(file_idx)
end


function get_index_file(idx)
	if CurOpenZip then 
		return CurOpenZip:get_name(idx,luazip.FL_UNCHANGED)
	end
end

function get_file_nums()
	return CurOpenZip and CurOpenZip:get_num_files()
end

--return : {
	-- name = "test/text.txt",
	-- index = 2,
	-- crc = 635884982,
	-- size = 14,
	-- mtime = 1296450278,
	-- comp_size = 14,
	-- comp_method = 0,
	-- encryption_method = 0,
-- }
function get_stat(fileInZip)
	return CurOpenZip and CurOpenZip:stat(fileInZip)
end

function get_size(fileInZip)
	if CurOpenZip then 
		local s = CurOpenZip:stat(fileInZip)
		return  s and s.size;
	end
end
-----------------------------------------------------------------
--path = 'c:/a/b/' or "a/b/"
--zipFile = 'a/b/filename.apc' --注意文件路径不能出现非常规字符
--压缩文件中内容不能为空
 --zipfile：是生成的目标文件，path是准备压缩的文件夹路径
 --压缩时 仅压缩文件夹内的内容不包含文件夹本身。
function zip(zipFile,path)
	assert(type(zipFile) == 'string' )
	local temp = zipFile .. '.temp'
	sysDisk.file_delete(temp)
	create(temp)
	local function loop_dir(curPath,zipPath)
		for line in lfs.dir(curPath) do 
			if line ~= '.' and line ~= '..' then 
				local val = curPath .. line 
				local zipVal = zipPath .. line
				if lfs.attributes(val,'mode') == 'directory' then 
					add_folder(zipVal)
					loop_dir(val .. '/',zipVal .. '/')
				else 
					add{file = zipVal,mode = 'file',src = val}
				end
			end
		end
	end
	loop_dir(path,'')
	close()
	local zipFilePath,zipFileName = string.match(zipFile,'(.+/?)[^/]+'), string.match(zipFile,'.+/?([^/]+)')
	sysDisk.file_rename(zipFilePath,zipFileName .. '.temp',zipFileName,true)
end

 --zipfile：是要解压的文件，path是目标路径
 --path = 'c:/a/b/' or "a/b/"
--zipFile = 'a/b/filename.apc' --注意文件路径不能出现非常规字符
 --确保目标文件夹存在
function unzip(zipfile,path)
	
	local curPath = string.match(path , '(.+)/')
	if lfs.attributes(curPath,'mode') ~= 'directory' then
		return 
	end
	local tempPath = curPath.. '.temp/'
	if lfs.attributes(tempPath,'mode') == 'directory' then
		sysDisk.dir_delete(tempPath) 
	end 
	lfs.mkdir(tempPath)
	create(zipfile)
	local nums = get_file_nums()
	local fileInZip;
	if nums ~= 0 then 
		for id = 1,nums do 
			fileInZip = get_index_file(id)
			if string.sub(fileInZip,-1,-1) == '/' then 
				lfs.mkdir(tempPath .. fileInZip)
			else 
				unzip_file(id,tempPath .. fileInZip)
			end
		end
	end
	close()
	sysDisk.dir_delete(path) 
	rename(string.match(tempPath,'(.+)/'),string.match(path,'(.+)/'))
	
end


--ar,fileIndex(压缩文件中的位置,全路径并注意大小写),diskPath(解压后文件的位置)
--参数示例:ar、'test/a.doc'、'test/test2.doc'
function unzip_file(fileIndex,diskPath)
	local stat = CurOpenZip:stat(fileIndex)
	if stat then 
		local file = CurOpenZip:open(fileIndex)
		local str = ''
		if stat.size > 0 then 
			str = file:read(stat.size)
		end
		file:close() 
		file = open(diskPath,"w+b")
		file:write(str)
		file:close() 
		return true
	end 
end