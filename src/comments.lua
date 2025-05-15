local aprint = require"src/advanced_print"

--- @class CommentData Contains data about an actively displayed comment.
--- @field str string The comment string.
--- @field duration number The duration of the comment in seconds.
--- @field timer number The amount of time that has passed since the comment was created in seconds.
--- @field get_target_pos fun():userdata A function that returns the target position of the comment.
--- @field col integer The color of the comment.
--- @field outline_col integer? The outline color of the comment. nil for no outline.

--- Creates a new comment that follows the target.
--- @param self CommentSystem The comment system to add the comment to.
--- @param str string The comment string to display.
--- @param col integer The color of the comment.
--- @param outline_col integer? The outline color of the comment. Nil for no outline.
--- @param target any An arbitrary key to identify the target of the comment. Only one comment can be active for each target at a time.
--- @param get_target_pos fun():userdata A function that returns the target position of the comment.
local function add_comment(self,str,col,outline_col,target,get_target_pos)
	self.active[target] = {
		str = str,
		duration = self.delay_buffer + #str * self.seconds_per_char,
		timer = 0,
		get_target_pos = get_target_pos,
		col = col,outline_col = outline_col,
	}
end

--- Advances the timers of all active comments and removes those that have expired.
--- @param self CommentSystem The comment system to update.
--- @param dt number The number of seconds since the last update.
local function advance_time(self,dt)
	local k,v = next(self.active)
	while v do
		local next_k,next_v = next(self.active,k)

		v.timer += dt
		if v.timer >= v.duration then
			self.active[k] = nil
		end
		k,v = next_k,next_v
	end
end

--- Draws all active comments on the screen.
--- @param self CommentSystem The comment system to draw.
--- @param screen_size userdata The size of the screen.
local function draw_comments(self,screen_size)
	for _,comment in pairs(self.active) do
		local pos = comment.get_target_pos()
		aprint(comment.str,pos.x,pos.y,comment.col,vec(0.5,1),"center",comment.outline_col,screen_size)
	end
end

--- Creates a new system for displaying comments on the screen.
--- @param seconds_per_char number The time that each character contributes to the comment's duration in seconds.
--- @param delay_buffer number The additional time added to all comments' durations in seconds.
--- @return CommentSystem comment_system The new comment system.
local function new(seconds_per_char,delay_buffer)
	--- @class CommentSystem Handles the timing and display of limited lifespan text that follows targets.
	--- @field active table<any,CommentData> A table of active comments.
	--- @field seconds_per_char number The time that each character contributes to the comment's duration in seconds.
	--- @field delay_buffer number The additional time added to all comments' durations in seconds.
	local comments = {
		active = {},
		seconds_per_char = seconds_per_char,
		delay_buffer = delay_buffer,
		add_comment = add_comment,
		advance_time = advance_time,
		draw_comments = draw_comments,
	}
	return comments
end

return {
	new = new,
}