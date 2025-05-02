--- @class Cursor Data describing a cursor.
--- @field sprite integer The sprite index of the cursor.
--- @field pivot userdata The hotspot of the cursor relative to the sprite.

--- Draws the cursor to the screen.
--- @param self CursorHandler The cursor data.
--- @param mouse_pos userdata The position of the mouse on the screen.
local function draw(self,mouse_pos)
	local spr_pos = mouse_pos-self.cursor.pivot
	spr(self.cursor.sprite,spr_pos.x,spr_pos.y)
end

--- Sets the current cursor.
--- @param self CursorHandler The cursor data.
--- @param cursor_name string The name of the cursor to switch to.
local function set_cursor(self,cursor_name)
	if not self.catalog[cursor_name] then
		error("Invalid cursor key: "..tostring(cursor_name))
	end

	self.cursor = self.catalog[cursor_name]
end

--- Creates a cursor handler.
--- @param catalog table<string,Cursor> A table of cursors.
--- @param initial_cursor string The name of the initial cursor.
--- @return CursorHandler cursor_data The initialized cursor data.
local function new(catalog,initial_cursor)
	--- @class CursorHandler Data regarding the cursor state.
	--- @field catalog table<string,Cursor> A table of cursors.
	--- @field cursor Cursor The current cursor.
	local cursor_handler = {
		catalog = catalog,
		draw = draw,
		set_cursor = set_cursor,
	}
	cursor_handler:set_cursor(initial_cursor)
	return cursor_handler
end

return {
	new = new,
}