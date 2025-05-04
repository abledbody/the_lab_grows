--- @type table<string,ScreenData>
return {
	start = {
		script = "src/screen_behaviors/start.lua",
		bg = {
			sprite = 65,
			pos = vec(30,61),
		},
		fg = {
			sprite = 66,
			pos = vec(31,93),
		},
		lighting = {
			sprite = 73,
			pos = vec(30,61),
		},
		path = {
			nodes = {
				vec(88,206),
				vec(410,206),
			},
			edges = {
				userdata("i32",2,"0000000100000002"),
			}
		},
		regions = {
			{pos = vec(67,156), size = vec(17,15), name = "monitor"},
		},
		music = 0,
	}
}