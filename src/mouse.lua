-- I'm not afraid to put non-instanced state in here, because input by definition
-- is global. Just keep in mind that most feature functionality is not like this.
local last_mb = 0 --- @type integer The last mouse button state.
local mb = 0 --- @type integer The current mouse button state.
local mouse_delta = vec(0,0) --- @type userdata The mouse delta from the last frame.
local mouse_pos = vec(0,0) --- @type userdata The current mouse position.

--- Must be called at the start of each frame to update the mouse state.
local function frame_start()
	local mx,my,new_mb = mouse()
	local new_mouse_pos = vec(mx,my)
	mouse_delta = new_mouse_pos-mouse_pos
	mouse_pos = new_mouse_pos
	last_mb = mb
	mb = new_mb
end

--- Checks if a mouse button is currently pressed.
--- @param button integer? The mouse button to check. Defaults to 0 (lmb)
--- @return boolean is_pressed Whether the button is currently pressed.
local function pressed(button)
	button = button or 0
	return mb&(1<<button) ~= 0
end

--- Checks if a mouse button was pressed this frame.
--- @param button integer? The mouse button to check. Defaults to 0 (lmb)
--- @return boolean was_pressed Whether the button was pressed this frame.
local function down(button)
	button = button or 0
	return ~last_mb&mb&(1<<button) ~= 0
end

--- Checks if a mouse button was released this frame.
--- @param button integer? The mouse button to check. Defaults to 0 (lmb)
--- @return boolean was_released Whether the button was released this frame.
local function up(button)
	button = button or 0
	return last_mb&~mb&(1<<button) ~= 0
end

local function position()
	return mouse_pos
end

local function delta()
	return mouse_delta
end

return {
	frame_start = frame_start,
	pressed = pressed,
	down = down,
	up = up,
	position = position,
	delta = delta,
}