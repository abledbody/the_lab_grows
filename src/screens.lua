--- @class ScreenData The simplest immutable form of a screen which defines how it works.
--- @field bg Decoration The background sprite.
--- @field fg Decoration The foreground sprite.
--- @field lighting Decoration The lighting sprite.
--- @field path {nodes:[Node], edges:[Edge]} The path data.
--- @field music integer? The music index to play while the screen is active.

local m_pathfinding = require"src/pathfinding"

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
	local screen = {
		data = data,
		path = m_pathfinding.new_path(data.path.nodes, data.path.edges),
		enter = enter,
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
}