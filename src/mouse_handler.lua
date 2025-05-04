local m_clicking = require("src/clicking")

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

		--- @type ScreenScriptContext 
		local screen_ctx = {
			event = {
				type = "hover",
				region = hovered_region,
				region_script = hovered_region_script,
				mouse_pos = mouse_pos,
			},
			screen = screen,
			intent = {
				cursor = "go_to",
				consume_input = false,
			},
		}

		screen:event(screen_ctx)

		if m_clicking.down() then
			screen_ctx.event.type = "click"
			screen:event(screen_ctx)
			if not screen_ctx.intent.consume_input then
				player:go_to_mouse(screen,mouse_pos)
			end
		end

		cursor_data:set(screen_ctx.intent.cursor)

	elseif m_clicking.down() then
		player:go_to_mouse(screen,mouse_pos)
	end
end

return {
	update = update,
}