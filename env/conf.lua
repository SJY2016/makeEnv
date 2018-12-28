local conf = {	
	--key 对应的值如果是文件则从文件取对应的数据进行配置。
	--key值对应的是表则直接使用表内数据。
	projectName = 'AP.MakeApcad';  --工程名
	tempFilePath = 'config/files/';-- 规定程序在安装后由程序生成的文件存放位置。目的是卸载时可以将生成的文件一并删除。
	-- main
	keyword = 'config/keyword.lua'; --类似于js配置
	lang = 'config/lang.lua'; --提供的语言库及当前版本管理。
	tabBar = 'config/page.lua';--左侧工作区及界面样式配置。
	menu = 'config/menu.lua';--左侧工作区及界面样式配置。
	toolbar = 'config/toolbar.lua';
	loads = { --必须存在
		'keyword'; --如果有keyword 必须放在第一位
		'lang';--如果有lang 必须放在第keyword 后，其他界面模块之前
		'menu';
		'toolbar';
		'tabBar';
	};
}
return conf