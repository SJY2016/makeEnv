local keywords = {
	['AP.Page.Browser'] = {
		tabtitle = 'GreenMark';
		file = 'browser/main.lua';
		hwnd=  {type = 'function',value ="get_hwnd"}; 
		onInit=  {type = 'function',value ="on_init"}; 
		-- onLoad=  {type = 'function',value ="on_load"}; 
		onUnload=  {type = 'function',value ="on_unload"}; 
	};
}
return keywords