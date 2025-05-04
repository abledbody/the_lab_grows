--- @class ScreenData The simplest immutable form of a screen which defines how it works.
--- @field script string The path to the script that defines the screen's behavior.
--- @field bg Decoration The background sprite.
--- @field fg Decoration The foreground sprite.
--- @field lighting Decoration The lighting sprite.
--- @field regions [Region]
--- @field path {nodes:[Node],edges:[Edge]} The path data.
--- @field music integer? The music index to play while the screen is active.

--- @class ScreenScript A script that defines the behavior of a screen.
--- @field regions table<string,RegionScript>? A table of region scripts, where the key is the name of the region and the value is a script that defines the behavior of that region.
--- @field on_screen_event? fun(ctx:ScreenScriptContext) A function that handles events for the screen.

--- @class Region A region of the screen that can be interacted with.
--- @field pos userdata The position of the region.
--- @field size userdata The size of the region.
--- @field name string The name of the region.

--- @class ScreenIntent The intentions of an event after it has been processed.
--- @field cursor string The name of the cursor to set.
--- @field consume_input boolean Whether to consume the input event or not.

--- @class ScreenScriptContext The context of the screen script.
--- @field screen Screen The screen that the script is running on.
--- @field intent ScreenIntent The intent of the event.
--- @field event ScreenEvent The event that triggered the script.

--- @class ScreenEvent
--- @field type string The type of event that occurred.
--- @field [any] any

--- @alias ScreenEventHandler fun(ctx:ScreenScriptContext) A function that handles events for a screen.

local m_pathfinding = require"src/pathfinding"

--- Finds the first region that contains the given point.
--- @param regions [Region] The regions to search.
--- @param query_pt userdata The point to search for.
--- @return Region? region The region that contains the point, or nil if none do.
local function locate_region(regions,query_pt)
	for region in all(regions) do
		local high = region.pos + region.size
		if region.pos.x <= query_pt.x and query_pt.x < high.x and
			region.pos.y <= query_pt.y and query_pt.y < high.y then
			return region
		end
	end
end

--- Finds the first region that contains the given point on the screen.
--- @param self Screen The screen to search.
--- @param query_pt userdata The point to search for.
--- @return Region? region The region that contains the point, or nil if none do.
local function locate_region_on_screen(self,query_pt) 
	return locate_region(self.data.regions,query_pt)
end

--- @class RegionScript A script defining the behavior of a region.
--- @field [string] fun(ctx:ScreenScriptContext) An event handler for the region.

--- Handles events regarding regions on the screen.
--- @param ctx ScreenScriptContext The context of the screen script.
local function region_events(ctx)
	local event = ctx.event
	local region_script = event.region_script
	if not (region_script and region_script[event.type]) then return end

	region_script[event.type](ctx)

	if event.type == "click" then
		ctx.intent.consume_input = true
	end
end

--- Sends an event to the screen script.
--- @param self Screen The screen that's being hovered over.
--- @param ctx ScreenScriptContext Context for the screen script.
local function event(self,ctx)
	if not self.script then return end

	if self.script.on_screen_event then
		self.script.on_screen_event(ctx)
		return
	end
	
	region_events(ctx)
end

--- Initializes the screen.
--- @param self Screen
local function enter(self)
	music(self.data.music or -1)
end

--- Creates a new screen object from some screen data.
--- @param data ScreenData The screen data to create the screen from.
--- @return Screen screen The new screen object.
local function new_screen(data)
	--- @class Screen The active variant of a screen with methods.
	--- @field data ScreenData The screen data.
	--- @field path Path The precached pathfinding data.
	--- @field script ScreenScript The script that defines the screen's behavior.
	local screen = {
		data = data,
		path = m_pathfinding.new_path(data.path.nodes, data.path.edges),
		script = include(data.script),
		enter = enter,
		locate_region_on_screen = locate_region_on_screen,
		event = event,
	}
	return screen
end

--- Creates a table of screen objects from a table of screen data.
--- @param screens_data table<string,ScreenData> The screen data to import.
--- @return table<string,Screen> screens The screens created from the data.
local function import(screens_data)
	local screens = {}

	for k,data in pairs(screens_data) do
		screens[k] = new_screen(data)
	end

	return screens
end

return {
	import = import,
	region_events = region_events,
}