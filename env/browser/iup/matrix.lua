--[[
/*
*Author:Sun JinYang
*Begin:2018年03月02日
*Description:
*	此文件用来处理iup.Matrix。
*Record:（Time Content）
*	2018年4月20日 添加dat 属性及其对应的数据结构和操作方法。
*/
--]]
--[[
数据结构：
	iupElement:值为userdata 类型，类保存的创建的iup matrix对象
	map：值为boolean类型，当控件被map后，设置map的值为true，否则为nil。
	dat:值为table类型，存储矩阵列表需要的数据及样式信息。dat表中数据结构如下：
		heads：对应值为table类型，设置矩阵第0行的样式及内容。表中数组结构为cell显示的内容，非数组的部分用来设置矩阵第0行的整体的属性，数组由表结构构成。
			可允许设置的属性如下:
				IUP 提供的属性：
					ALIGNMENTLIN0:设置第0行的文本对齐方式。	
					...
			数组表中属性如下：（注意如果数组从0开始则认为存在第0列）
				title:对应值为string类型，设置cell显示的文本。
				key：对应的值可以是任意类型（需保证其唯一性），用来设置关键字。
				width:对应值为number类型，设置当前cell的宽度。缺省使用默认设置。
				fgcolor、bgcolor、...
		datas：对应值为table类型，设置单元格显示的内容。
		cbs:对应值为table类型，设置矩阵需要的回调函数。table为数组结构，数组的每一项都由table构成，子table包含的属性如下：
			name:值为string类型，设置要使用的回调函数名称。
			fun：值为function类型，设置的回调函数。
			for example :
				{
					{name = 'map_cb',fun = function() print('map_cb') end};
					{name = 'map_cb',fun = function() print('map_cb') end};
					...
				}
		styles:对应值为table类型，用来设置matrix的全局样式属性。（使用iup.matrix 的属性）
			
		
接口函数：
--]]
--[[
use note:
	heads对应的数组表如果从0开始则认为包含第0列。
--]]
local _M = {}
local modname = ...
_G[modname] = _M
package.loaded[modname] = _M

local rpath,path = require 'sys.tools'.get_path(modname)
local iupClass_ = require (rpath .. 'iupClass').Class
local iup = require 'iuplua'
require 'iupluacontrols'

local print = print
local type = type
local ipairs = ipairs
local pairs = pairs
local string = string
local tonumber = tonumber
local table = table
local tostring = tostring
local assert = assert
local error = error

_ENV = _M

Class = {}

iupClass_:met(Class)

function Class:new(arg)
	local t = self:met()
	arg = arg or {}
	t:init_control(iup.matrix(arg))
	t:init()
	return t
end

--创建完成时，初始化矩阵相关内容
function Class:init()
	self:add_iup_cbf{key = 'map_cb',cbf =function(key)self:map_cb(key) end}
	self:add_iup_cbf{key ='edition_cb',cbf =function(key)self:edition_cb(key) end}
	self:add_iup_cbf{key = 'value_edit_cb',cbf = function(key)self:value_edit_cb(key) end}
	self:add_iup_cbf{key ='fgcolor_cb',cbf = function(key)self:fgcolor_cb(key) end}
	self:add_iup_cbf{key = 'drop_cb',cbf = function(key)self:drop_cb(key) end}
	self:add_iup_cbf{key = 'dropcheck_cb',cbf =function(key)self:dropcheck_cb(key) end}
	self:add_iup_cbf{key = 'click_cb',cbf =function(key)self:click_cb(key) end}
	self:add_iup_cbf{key = 'bgcolor_cb',cbf =function(key)self:bgcolor_cb(key) end}
	self:add_iup_cbf{key = 'dropselect_cb',cbf =function(key)self:dropselect_cb(key) end}
	self:add_iup_cbf{key = 'button_cb',cbf =function(key)self:button_cb(key) end}
	self:add_iup_cbf{key = 'action_cb',cbf =function(key)self:action_cb(key) end}
	self:add_iup_cbf{key = 'togglevalue_cb',cbf =function(key)self:togglevalue_cb(key) end}
	self:add_iup_cbf{key = 'menudrop_cb',cbf =function(key)self:menudrop_cb(key) end}
end


-----------------------------------------------------------------
--set attributes

--修改矩阵行数
function Class:set_numlin(lin)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.numlin = lin
end

--修改矩阵控件的列数
function Class:set_numcol(col)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.numcol = col
end

--arg = {--lin,--col}
function Class:set_lincol(arg)
	if not self:warning() then return end 
	local matrix = self:get_control()
	if arg and arg.lin then 
		matrix.numlin = arg.lin
	end
	if arg and arg.col then 
		matrix.numcol = arg.col
	end
end

function Class:set_numlin_visible(lin)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.numlin_visible = lin
end

function Class:set_numcol_visible(col)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.numcol_visible = col
end

--arg = {--lin,--col}
function Class:set_visible(arg)
	if not self:warning() then return end 
	local matrix = self:get_control()
	if arg and arg.lin then 
		matrix.numlin_visible = arg.lin
	end
	if arg and arg.col then 
		matrix.numcol_visible = arg.col
	end
end

--设置 矩阵的宽高(char)
--size:'WxH'
function Class:set_size(size)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.size = size
	if self.map then 
	--	iup.
	end
end

--设置 矩阵的宽高(像素)
--size:'WxH'
function Class:set_rastersize(size)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.rastersize = size
	if self.map then 
		--
	end
end



--set readonly
--status:true or nil
function Class:set_readonly(status)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.readonly = status and 'yes' or 'no'
end

function Class:setcell(lin,col,val)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix:setcell(lin,col,val)
end

function Class:getcell(lin,col)
	if not self:warning() then return end 
	local matrix = self:get_control()
	return matrix:getcell(lin,col)

end

function Class:redraw(val)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.redraw = val
end

function Class:get_curLin()
	if not self:warning() then return end 
	local focusCell = self:get_focusCell() 
	if not focusCell then focusCell = '1:1' self:set_focusCell(focusCell) end
	local lin,col = string.match(focusCell,'(%d+):(%d+)')
	return tonumber(lin),tonumber(col)
end

function Class:set_focusCell(cell)
	if not self:warning() then return end 
	self:get_control().FOCUSCELL = cell
end

function Class:get_focusCell()
	if not self:warning() then return end 
	local matrix = self:get_control()
	return matrix.FOCUSCELL
end

function Class:get_numCol()
	if not self:warning() then return end 
	local matrix = self:get_control()
	return tonumber(matrix.NUMCOL)
end

function Class:set_numLin(lin)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.NUMLIN = lin
end

function Class:set_origin(lin)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.ORIGIN = lin

end

function Class:get_numLin()
	if not self:warning() then return end 
	local matrix = self:get_control()
	return tonumber(matrix.NUMLIN)
end

function Class:delete_lin(val)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.DELLIN = val
end

function Class:add_linDat(dat,pos)
	if not self:warning() then return end 
	local matrix = self:get_control()
	matrix.ADDLIN = pos
	for col,v in pairs(dat) do 
		self:setcell(pos+1,col,v)
	end
	self:redraw('L' .. (pos+1))
end

function Class:turn_linUp()
	if not self:warning() then return end 
	local lin = self:get_curLin()
	if lin <= 1 then return end 
	local colNum = self:get_numCol()
	local temp = {}
	for i = 0,colNum do 
		temp[i] = self:getcell(lin - 1,i)
	end
	self:delete_lin(lin-1)
	self:add_linDat(temp,lin-1)
	--self:set_origin(lin)
	self:mark_lin(lin-1)
	self:set_focusCell(lin)
end

function Class:turn_linDown()
	if not self:warning() then return end 
	local lin = self:get_curLin()
	local linNum = self:get_numLin()
	if lin == 0 or linNum == 0 then return end 
	if linNum == lin then 
		self:set_numLin(lin +1)
	end

	local colNum = self:get_numCol()
	local temp = {}
	for i = 0,colNum do 
		temp[i] = self:getcell(lin,i)
	end
	self:delete_lin(lin)
	self:add_linDat(temp,lin)
	self:set_focusCell((lin+1) .. ':1')
	self:mark_lin(lin+1)
end


function Class:reg_onBtnUp(f)
	assert(type(f) == 'function','The function "reg_obBtnUp" need a parameter of a function type !')
	self.btnFuns = self.btnFuns or {up = {},down = {}}
	self.btnFuns.up[f] = true
end

function Class:reg_onBtnDown(f)
	assert(type(f) == 'function','The function "reg_obBtnUp" need a parameter of a function type !')
	self.btnFuns = self.btnFuns or {up = {},down = {}}
	self.btnFuns.down[f] = true
end

function Class:reg_onBtn(f)
	assert(type(f) == 'function','The function "reg_obBtnUp" need a parameter of a function type !')
	self.btnFuns = self.btnFuns or {up = {},down = {}}
	self.btnFuns[f] = true
end

function Class:on_change(status) --status = 'up' or 'down'
	self.btnFuns = self.btnFuns or {up = {},down = {}}
	for k,v in pairs(self.btnFuns) do 
		if type(k) == 'string' and k == status then 
			for m,n in pairs(v) do 
				if type(m) == 'function' then 
					m(self:get_control())
				end
			end
		elseif type(k) == 'function' then 
			k(self:get_control())
		end
	end
end

--arg = {value = 'string',lin=,col=}
function Class:get_valuePos(arg)
	if not arg.value then return end 
	if arg.lin then 
		local colNum = self:get_numCol()
		for i = 0,colnum do 
			if self:getcell(arg.lin,i) == arg.value then 
				return {col = i}
			end
		end
	elseif arg.col then 
		local linNum = self:get_numLin()
		for i = 0,linNum do 
			if self:getcell(i,arg.col) == arg.value then 
				return {lin = i}
			end
		end
	else 
		local colNum = self:get_numCol()
		local linNum = self:get_numLin()
		for i = 0,linNum do 
			for j = 0,colNum do 
				if self:getcell(i,j) == arg.value then 
					return {lin =i,col = j}
				end
			end
		end
	end
end



--arg = {--lin,--col,--headSelect,--bgcolor,--headLin}
function Class:set_tog(arg)
	if arg.headSelect  then 	
		arg.headLin = arg.headLin  or 1
	end
	self:reg_callback('dropcheck_cb',function(self,lin,col)
		if arg.lin and arg.col and lin == arg.lin and col == arg.col then 
			return iup.CONTINUE
		elseif arg.lin and not arg.col and lin == arg.lin then 
			return iup.CONTINUE
		elseif arg.col and not arg.lin and col == arg.col then 
			if arg.headLin and  arg.headSelect and lin >= arg.headLin then 	
				return iup.CONTINUE
			elseif arg.headLin and   lin >= arg.headLin then 	
				return iup.CONTINUE
			end
			return iup.CONTINUE
		end
	end)
	self:reg_callback('edition_cb',function(self,lin,col)
		if arg.lin and arg.col and lin == arg.lin and col == arg.col then 
			return iup.IGNORE
		elseif arg.lin and not arg.col and lin == arg.lin then 
			return iup.IGNORE
		elseif arg.col and not arg.lin and col == arg.col then 
			return iup.IGNORE
		end
		
	end)
	
	if arg.headLin and arg.headLin ~= 0 then 
		local matrix = self:get_control()
		matrix.numlin = matrix.numlin or arg.headLin
		matrix['bgcolor' ..  arg.headLin .. ':*'] =arg.bgcolor or '216 216 216'
	end
	if arg.headSelect then 
		local function loop_togs(number,statistics)  
			local matrix = self:get_control()
			local curNumber = number;
			for lin = arg.headLin , self:get_numLin() do 
				if not statistics then 
					matrix['TOGGLEVALUE'  .. lin .. ':'.. arg.col ] = number
				else 
					if lin ~=  arg.headLin and 1 ~= tonumber(matrix['TOGGLEVALUE'  .. lin .. ':'.. arg.col]) then 
						return true
					end
				end
			end
		end
	
		self:reg_callback('togglevalue_cb',function(matrix,lin,col,number)
			if lin == arg.headLin then 
				loop_togs(number)  
			else 
				if arg.headLin then 
					if loop_togs(number,true)   then 
						matrix['TOGGLEVALUE'  .. arg.headLin .. ':'.. col] = 0
					else 
						matrix['TOGGLEVALUE'  .. arg.headLin .. ':'.. col] = 1
					end
				end
			end
			matrix.redraw = col
		end)
	end
end

--arg = {col = ,}
function Class:set_colTog(arg)
	self:set_tog(arg)
end

--arg = {--lin,--col,--dropCb}
function Class:set_drop(arg)
	self:reg_callback('dropcheck_cb',function(self,lin,col)
		if arg.lin and arg.col and lin == arg.lin and col == arg.col then 
			return iup.DEFAULT
		elseif arg.lin and not arg.col and lin == arg.lin then 
			return iup.DEFAULT
		elseif arg.col and not arg.lin and col == arg.col then 
			return iup.DEFAULT
		end
	end)

	local dropCb = arg.dropCb
	if type(dropCb) == 'function' then 
		self:reg_callback('drop_cb',function(self,drop,lin,col)
			if arg.lin and arg.col and lin == arg.lin and col == arg.col then 

				return dropCb(self,drop,lin,col)
			elseif arg.lin and not arg.col and lin == arg.lin then 
				return dropCb(self,drop,lin,col)
			elseif arg.col and not arg.lin and col == arg.col then 
				return dropCb(self,drop,lin,col)
			end
		end)
	end
end

function Class:set_colDrop(col,dropCb)
	return self:set_drop{col = col,dropCb = dropCb}
end

function Class:set_dropselect()
	self:reg_callback('dropselect_cb',function(self,lin,col,drop,t,i,v)
		--t:text
		--i:position
		--v:0 or 1 ;0 is old 1 is new
		if v == 1 then 
			return iup.CONTINUE
		end
		return iup.CONTINUE
	end)
end
-----------------------------------------------------------------
--set callback

--table:{lin,col,readonly}
--funtion:return iup.IGNORE
function Class:edition_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:edition_cb(lin, col, mode, update)
		return temp:run_callbacks(key,self,lin,col,mode,update)
	end
end

function Class:action_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:action_cb(selfKey,lin, col, edition,value)
		return temp:run_callbacks(key,self,selfKey,lin,col,edition,value)
	end
end

function Class:togglevalue_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:togglevalue_cb(lin,col,status)
		return temp:run_callbacks(key,self,lin,col,status)
	end
end

function Class:map_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:map_cb()
		temp.map = true
		temp:init_matrix()
		return temp:run_callbacks(key,self)
	end
end

function Class:value_edit_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:value_edit_cb(lin,col,newstr)
		return temp:run_callbacks(key,self,lin,col,newstr)
	end
end


function Class:fgcolor_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:fgcolor_cb(lin,col)
		return temp:run_callbacks(key,self,lin,col) or iup.IGNORE
	end
end

function Class:bgcolor_cb(key)
	if not self:warning() then return end 
	local temp = self
	local matrix = self:get_control()
	function matrix:bgcolor_cb(lin,col)
		return temp:run_callbacks(key,self,lin,col) or iup.IGNORE
	end
end

function Class:drop_cb(key)
	local control = self:get_control()
	if not self:warning(control) then return end 
	local temp = self
	function control:drop_cb(drop,lin,col)
		local val = temp:run_callbacks(key,self,drop,lin,col)
		return val or iup.IGNORE
	end
end

function Class:menudrop_cb(key)
	local control = self:get_control()
	if not self:warning(control) then return end 
	local temp = self
	function control:menudrop_cb(drop,lin,col)
		local val = temp:run_callbacks(key,self,drop,lin,col)
		return val or iup.IGNORE
	end
end



function Class:dropcheck_cb(key)
	local temp = self
	local control = self:get_control()
	if not self:warning(control) then return end 
	function control:dropcheck_cb(lin,col)
		local val = temp:run_callbacks(key,self,lin,col)
		return val or iup.IGNORE
	end
end


function Class:click_cb(key)
	local temp = self
	local control = self:get_control()
	if not self:warning(control) then return end 
	function control:click_cb(lin,col,status)
		return temp:run_callbacks(key,self,lin,col,status) or iup.IGNORE
	end
end

function Class:dropselect_cb(key)
	local temp = self
	local control = self:get_control()
	if not self:warning(control) then return end 
	function control:dropselect_cb(lin,col,drop,t,i,v)
		return temp:run_callbacks(key,self,lin,col,drop,t,i,v)
	end
end

function Class:button_cb(key)
	local temp = self
	local control = self:get_control()
	if not self:warning(control) then return end 
	function control:button_cb(button,pressed,x,y,status)
		return temp:run_callbacks(key,self,button,pressed,x,y,status)
	end
end
---------------------------------------------------------
--extend
function Class:mark_cell(lin,col)
	local matrix =self:get_control()
	matrix['mark' .. matrix.focuscell] = 0
	matrix['mark' ..lin .. ':' .. col] = 1
	matrix.focuscell = lin .. ":" .. col
end

function Class:mark_lin(lin)
	local matrix =self:get_control()
	--matrix.marked = 'NULL'
	for col = 0,tonumber(matrix.numcol) do 
		matrix['mark' ..lin .. ':' .. col] = 1
	end
	self:redraw('ALL')
end

function Class:mark_lin_s()
end

---------------------------------------------------------
-- dat op

function Class:set_dat(dat)
	self.dat = dat
end

function Class:init_matrix_style(dat)
	if type(dat) ~= 'table' then return end 
	local matrix = self:get_control()
	for k,v in pairs(dat) do 
		matrix[k] = v
	end
end

function Class:init_matrix_head(dat)
	if type(dat) ~= 'table' then return end 
	local matrix = self:get_control()
	
end

function Class:init_matrix_body(dat)
end

function Class:init_matrix_cbs(cbs)
end

function Class:init_matrix()
	if not self.dat then return end 
	self:init_matrix_style(self.styles)
	self:init_matrix_head(self.heads)
	self:init_matrix_body(self.datas)
	self:init_matrix_cbs(self.cbs)
end
