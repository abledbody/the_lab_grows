-- I'm not afraid to put non-instanced state in here, because input by definition
-- is global. Just keep in mind that most feature functionality is not like this.
local last_mb = 0 --- @type integer The last mouse button state.
local mb = 0 --- @type integer The current mouse button state.

--- Must be called at the start of each frame to update the mouse button state.
--- @param new_mb integer The new mouse button state.
local function frame_start(new_mb)
	last_mb = mb
	mb = new_mb
end

--- Checks if a mouse button is currently pressed.
--- @param button integer The mouse button to check.
--- @return boolean is_pressed Whether the button is currently pressed.
local function pressed(button)
	return mb&(1<<button) ~= 0
end

--- Checks if a mouse button was pressed this frame.
--- @param button integer The mouse button to check.
--- @return boolean was_pressed Whether the button was pressed this frame.
local function down(button)
	return ~last_mb&mb&(1<<button) ~= 0
end

--- Checks if a mouse button was released this frame.
--- @param button integer The mouse button to check.
--- @return boolean was_released Whether the button was released this frame.
local function up(button)
	return last_mb&~mb&(1<<button) ~= 0
end

return {
	frame_start = frame_start,
	pressed = pressed,
	down = down,
	up = up,
}