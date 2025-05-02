--- @class Cursor
--- @field sprite integer
--- @field pivot userdata

--- @param self CursorData
--- @param mouse_pos userdata
local function draw(self,mouse_pos)
	if not self.cursor then return end
	local cursor = self.cursors[self.cursor]
	if not cursor then return end

	local spr_pos = mouse_pos-cursor.pivot
	spr(cursor.sprite,spr_pos.x,spr_pos.y)
end

--- @param cursors [Cursor]
--- @param initial_cursor integer
--- @return table
local function init(cursors,initial_cursor)
	--- @class CursorData
	--- @field cursors [Cursor]
	--- @field cursor integer
	local cursor = {
		cursors = cursors,
		cursor = initial_cursor,
		draw = draw,
	}
	return cursor
end

return {
	init = init,
}