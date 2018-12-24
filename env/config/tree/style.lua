return {
	attributes = { --如果是
		iconFileType = true;
		imageLeaf = 'res/default.bmp'; --系统默认文件节点图标
		rmenu = {file = 'sys/tree/tree_frame.lua',action = 'on_rbtn',};
		lbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_lbtn',};
		dlbtn = {file = 'sys/tree/tree_frame.lua',action = 'on_dlbtn',};
	};
	{
		attributes = {title = 'Project',state = 'EXPANDED'};
		{
		};
	};
}