local keywords = {
	['AP.Page.Browser'] = {
		tabtitle = 'GreenMark';
		file = 'browser/main.lua';
		hwnd =  {action ="get_hwnd"}; 
		onInit =  {action ="on_init"}; 
		onUnload=  {action ="on_unload"}; 
	};
	['AP.Menu.NewFile'] = {
		view = true;
		frame = true;
		action = "browser/action.new_file";
	};
	['AP.Toolbar.OpenFile'] = {
		view = true;
		frame = true;
		icon = 'res/save.bmp';
		action = "browser/action.open_file";
	};
	
				
}
return keywords