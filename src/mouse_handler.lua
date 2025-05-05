local m_clicking = require("src/clicking")
local m_events = require("src/events")

--- Handles the mouse's interactions with the screen.
--- @param screen Screen The screen that the mouse is interacting with.
--- @param mouse_pos userdata The position of the mouse.
--- @param cursor_data CursorHandler A handler for the cursor.
--- @param player Player The player object.
local function update(screen,mouse_pos,cursor_data,player)
	if screen.script then
		local hovered_region = screen:locate_region_on_screen(mouse_pos)
		local hovered_region_script = hovered_region
			and screen.script.regions
			and screen.script.regions[hovered_region.name]

		--- @type Event
		local event = m_events.new(
			"hover",
			{
				screen = screen,
				region = hovered_region,
				region_script = hovered_region_script,
				mouse_pos = mouse_pos,
			},
			{
				cursor = "go_to",
				consume_input = false,
			}
		)

		screen:send(event)

		if m_clicking.down() then
			event.type = "click"
			screen:send(event)
			if not event.output.consume_input then
				player:go_to_mouse(screen,mouse_pos)
			end
		end

		cursor_data:set(event.output.cursor)

	elseif m_clicking.down() then
		player:go_to_mouse(screen,mouse_pos)
	end
end

return {
	update = update,
}