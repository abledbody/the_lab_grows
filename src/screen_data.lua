--- @type table<string,ScreenData>
return {
	start = {
		bg = {
			{
				sprite = 65,
				pos = vec(30,61),
			}
		},
		fg = {
			{
				sprite = 66,
				pos = vec(31,93),
			}
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
		music = 0,
	}
}