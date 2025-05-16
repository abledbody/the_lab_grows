local m_mouse = require("src/mouse")
local m_events = require("src/events")

--- @class CommentEventData Contains data about the intent to display a comment.
--- @field str string The comment string.
--- @field col integer? The color of the comment. Defaults to 37.
--- @field outline_col integer? The outline color of the comment. -1 for no outline. Defaults to 0.
--- @field target "player"|"mouse" The target of the comment.

--- Creates a comment from an event output.
--- @param game GameState The state and module objects of the game.
--- @param comment_data CommentEventData? The data about the comment to display.
local function add_comment_from_event(game,comment_data)
	if not comment_data then return end

	local position_fetcher = ({
		player = function() return game.player.entity.path_follower:get_world_position() + vec(0,-64) end,
		mouse = function() return game.mouse_pos end,
	})[comment_data.target]

	if not position_fetcher then return end

	local outline_col = comment_data.outline_col
	if outline_col == -1 then
		outline_col = nil
	else
		outline_col = outline_col or 0
	end

	game.comment_system:add_comment(
		comment_data.str,
		comment_data.col or 37,
		outline_col,
		comment_data.target,
		position_fetcher
	)
end

local function click_events(event,handler)
	if m_mouse.pressed() then
		event.type = "click_held"
		handler(event)
	end
	if m_mouse.down() then
		event.type = "click_down"
		handler(event)
	end
	if m_mouse.up() then
		event.type = "click_up"
		handler(event)
	end
end

--- Handles the mouse's interactions with the screen.
--- @param game GameState The state and module objects of the game.
local function update(game)
	local screen = game.screen_manager.screen
	local mouse_pos = m_mouse.position()
	
	--- @type Event
	local event = m_events.new(
		"hover",
		{},
		{
			cursor = "go_to",
			consume_input = false,
		}
	)

	if (game.rotary_inventory:inside(mouse_pos)) then
		local rotary_inventory = game.rotary_inventory
		rotary_inventory:on_event(event)

		click_events(event,function(e) rotary_inventory:on_event(e) end)
	elseif screen.script then
		local hovered_region = screen:locate_region_on_screen(mouse_pos)

		event.input.screen = screen
		event.input.region = hovered_region
		event.input.region_script = hovered_region
			and screen.script.regions
			and screen.script.regions[hovered_region.name]
		
		screen:send(event)

		if m_mouse.pressed() then
			event.type = "click_held"
			screen:send(event)
		end
		if m_mouse.down() then
			event.type = "click_down"
			screen:send(event)
			if not event.output.consume_input then
				game.player:go_to_mouse(screen,mouse_pos)
			end
		end
		if m_mouse.up() then
			event.type = "click_up"
			screen:send(event)
		end
	elseif m_mouse.down() then
		game.player:go_to_mouse(screen,mouse_pos)
	end

	game.cursor_data:set(event.output.cursor)
	for comment in all(event.output.comments) do
		add_comment_from_event(game,comment)
	end
end

return {
	update = update,
}