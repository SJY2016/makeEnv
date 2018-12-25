
local msg = require 'sys.msg'

function create_dlgtree(...)
	return msg.run('create_dlgtree',...)
end

function frm_on_command(id)
	return msg.run('frm_on_command',id)
end

function on_command(id,scene)
	return msg.run('on_command',id,scene)
end

function on_timer(scene,id)
	return msg.run('on_timer',scene,id)
end

function on_paint(scene)
	return msg.run('on_paint',scene)
end

function render_objs(scene,mode)
	return msg.run('render_objs',scene,mode)
end

function render_drags(scene)
	return msg.run('render_drags',scene)
end

function free_scene(scene)
	return msg.run('free_scene',scene)
end

function begin_select(...)
	return msg.run('begin_select',...)
end

function select_main(index)
	return msg.run('select_main',index)
end

function end_select(...)
	return msg.run('end_select',...)
end

function on_mousewheel(scene,delta,x,y)
	return msg.run('on_mousewheel',scene,delta,x,y)
end
function on_mousemove(scene,flags,x,y)
	return msg.run('on_mousemove',scene,flags,x,y)
end
function on_lbuttondown(scene,flags,x,y)
	return msg.run('on_lbuttondown',scene,flags,x,y)
end
function on_lbuttonup(scene,flags,x,y)
	return msg.run('on_lbuttonup',scene,flags,x,y)
end
function on_lbuttondblclk(scene,flags,x,y)
	return msg.run('on_lbuttonup',scene,flags,x,y)
end
function on_mbuttondown(scene,flags,x,y)
	return msg.run('on_mbuttondown',scene,flags,x,y)
end
function on_mbuttonup(scene,flags,x,y)
	return msg.run('on_mbuttonup',scene,flags,x,y)
end
function on_mbuttondblclk(scene,flags,x,y)
	return msg.run('on_mbuttondblclk',scene,flags,x,y)
end
function on_rbuttondown(scene,flags,x,y)
	return msg.run('on_rbuttondown',scene,flags,x,y)
end
function on_rbuttonup(scene,flags,x,y)
	return msg.run('on_rbuttonup',scene,flags,x,y)
end
function on_rbuttondblclk(scene,flags,x,y)
	return msg.run('on_rbuttondblclk',scene,flags,x,y)
end

function on_keydown(scene,key)
	return msg.run('on_rbuttondblclk',scene,key)
end

function scene_onsize(scene,cx,cy)
	return msg.run('scene_onsize',scene,cx,cy)
end

function onidle(...)
	return msg.run('onidle',...)
end

function onchat(send,msg)
	return msg.run('onchat',send,msg)
end

function frmclose(...)
	msg.run('frmclose',...)
	iup.Close()
	return 
end

function on_gcad_msg(cmd,sc)
	return msg.run('on_gcad_msg',cmd,sc)
end




