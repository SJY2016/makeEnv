local conf = {	
	--key 对应的值如果是文件则从文件取对应的数据进行配置。
	--key值对应的是表则直接使用表内数据。
	projectName = 'AP.MakeApcad';  --工程名
	keyword = 'config/keyword.lua'; --类似于js配置
	lang = 'config/lang.lua'; --提供的语言库及当前版本管理。
	page = 'config/page.lua';--左侧工作区及界面样式配置。
	menu = 'config/menu.lua';--左侧工作区及界面样式配置。
	loads = { --必须存在
		'keyword'; --如果有keyword 必须放在第一位
		'lang';--如果有lang 必须放在第keyword 后，其他界面模块之前
		'menu';
		'page';
	};
}
return conf