local m_entities = require"src/entities"

local PLAYER_ANIMATIONS <const> = fetch(DATP.."anm/grim.anm") --- @type table<string,Animation>

--- @type AnimationListener
--- @param frame_events FrameEvents Every event that occurred in the calling frame.
local function animation_listener(_,frame_events)
	if frame_events.step then
		sfx(2)
	end
end

--- Creates a player entity.
--- @param path Path The path that the player is spawned on.
--- @param path_pos PathPosition The position on the path that the player is spawned at.
--- @return Player player The new player object.
local function new(path,path_pos)
	--- @class Player The player character.
	--- @field entity Entity The entity of the player.
	player = {
		entity = m_entities.new(path,path_pos,PLAYER_ANIMATIONS,3,animation_listener),
	}

	return player
end

return {
	new = new,
}