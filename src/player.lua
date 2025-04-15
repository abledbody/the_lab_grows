local m_entities = require"src/entities"

local PLAYER_ANIMATIONS <const> = fetch(DATP.."anm/grim.anm") --- @type table<string,Animation>

--- Creates the player
--- @param path Path The path that the player is spawned on.
--- @param path_pos PathPosition The position on the path that the player is spawned at.
--- @return Player player The new player object.
local function init(path,path_pos)
	--- @class Player
	--- @field entity Entity
	player = {
		entity = m_entities.new(path,path_pos,PLAYER_ANIMATIONS,3),
	}

	return player
end

return {
	init = init,
}