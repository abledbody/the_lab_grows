--- @class Decoration A single sprite with a position on a screen.
--- @field sprite number The sprite ID.
--- @field pos userdata The position of the sprite.

--- @class ScreenData The simplest immutable form of a screen which defines how it works.
--- @field bg [Decoration] The background sprites.
--- @field fg [Decoration] The foreground sprites.
--- @field path {nodes:[Node], edges:[Edge]} The path data.

local m_pathfinding = require"src/pathfinding"

--- Draws everything in the background layer.
--- @param self Screen The screen to draw.
local function draw_bg(self)
	for _,decoration in ipairs(self.data.bg) do
		spr(decoration.sprite, decoration.pos.x, decoration.pos.y)
	end
end

--- Draws everything in the foreground layer.
--- @param self Screen The screen to draw.
local function draw_fg(self)
	for _,decoration in ipairs(self.data.fg) do
		spr(decoration.sprite, decoration.pos.x, decoration.pos.y)
	end
end

--- Creates a new screen object from some screen data.
--- @param data ScreenData
--- @return Screen
local function new_screen(data)
	--- @class Screen The active variant of a screen with methods.
	--- @field data ScreenData The screen data.
	--- @field path Path The precached pathfinding data.
	local screen = {
		data = data,
		path = m_pathfinding.new_path(data.path.nodes, data.path.edges),
		draw_bg = draw_bg,
		draw_fg = draw_fg,
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