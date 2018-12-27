local keywords = {
	['AP.Page.Browser'] = {
		tabtitle = 'GreenMark';
		file = 'browser/main.lua';
		hwnd=  {type = 'function',value ="get_hwnd"}; 
		onInit=  {type = 'function',value ="on_init"}; 
		-- onLoad=  {type = 'function',value ="on_load"}; 
		onUnload=  {type = 'function',value ="on_unload"}; 
	};
	['AP.Menu.NewFile'] = {
		view = true;
		frame = true;
		action = {type = 'function',value ="action.new_file"}
	};
	['AP.Toolbar.OpenFile'] = {
		view = true;
		frame = true;
		icon = 'res/save.bmp';
		action = {type = 'function',value ="action.open_file"}
	};
	
				
}
return keywords