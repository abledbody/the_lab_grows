--- @type table<string,RegionScript>
local regions = {
	monitor = {
		--- @param ctx ScreenScriptContext
		hover = function(ctx) ctx.intent.cursor = "examine" end,
		--- @param ctx ScreenScriptContext
		click = function(ctx) end,
	},
}

--- @type ScreenScript
return {
	regions = regions,
}