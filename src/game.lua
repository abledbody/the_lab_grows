include"src/require.lua"

-- Dependencies
local m_screens = require"src/screens"
local m_player = require"src/player"
local m_pathfinding = require"src/pathfinding"
local m_clicking = require"src/clicking"

-- Constants
DT = 1/60
local DRAW_CPU <const> = true

-- Game state
local screen_key --- @type string
local screens --- @type table<string,Screen>
local player --- @type Player
local entities --- @type [Entity]

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())

	screens = m_screens.import(include"src/screen_data.lua")
	screen_key = "start"

	player = m_player.init(
		screens[screen_key].path,m_pathfinding.new_path_position(0.5,1)
	)
	entities = {
		player.entity,
	}
end

function _update()
	local mx,my,mb = mouse()
	local mouse_pos = vec(mx,my)
	m_clicking.frame_start(mb)
	local screen = screens[screen_key]

	if m_clicking.down(0) then
		player.entity.path_follower:set_target(
			screen.path:find_closest_path_position(mouse_pos)
		)
	end

	for entity in all(entities) do
		entity:animate(DT)
		entity:walk()
	end
end

function _draw()
	cls()

	local screen = screens[screen_key]
	screen:draw_bg()
	for entity in all(entities) do
		entity:draw()
	end
	screen:draw_fg()

	if DRAW_CPU then
		print(string.format("CPU: %.2f%%",stat(1)*100),0,0,37)
	end
end

include"src/error_explorer.lua"