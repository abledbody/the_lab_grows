--- @type table<string,RegionScript>
local regions = {
	monitor = {
		--- @type ScreenEventHandler
		hover = function(event) event.output.cursor = "examine" end,
		--- @type ScreenEventHandler
		click = function(event) end,
	},
}

--- @type ScreenScript
return {
	regions = regions,
}