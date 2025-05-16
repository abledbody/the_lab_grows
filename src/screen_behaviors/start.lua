--- @type table<string,RegionScript>
local regions = {
	monitor = {
		--- @type ScreenEventHandler
		hover = function(event) event.output.cursor = "examine" end,
		--- @type ScreenEventHandler
		click_down = function(event)
			event.output.comments = {
				{
					str = "The pinnacle of modern technology:\nThe cathode ray tube display.",
					target = "player",
				},
			}
		end,
	},
}

--- @type ScreenScript
return {
	regions = regions,
}