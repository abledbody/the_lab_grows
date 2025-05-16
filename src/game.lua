include"src/require.lua"

-- Dependencies
local m_player = require"src/player"
local m_pathfinding = require"src/pathfinding"
local m_mouse = require"src/mouse"
local m_screen_manager = require"src/screen_manager"
local m_lighting = require"src/lighting"
local m_entity_extensions = require"src/entity_extensions"
local m_decorations = require"src/decorations"
local m_cursor = require"src/cursor"
local m_mouse_handler = require"src/mouse_handler"
local m_comments = require"src/comments"
local m_rotary_inventory = require"src/rotary_inventory"

-- Constants
DT = 1/60
local DEBUG_MODE <const> = true
local ILLUMINATION_CT_INDEX <const> = 191

-- Game state
local game --- @type GameState

-- The game state is so self-explanatory that parameter/field comments have been
-- elided.

--- Initializes the root game state.
--- @param screen_size userdata
--- @param screen_manager ScreenManager
--- @param player Player
--- @param entities [Entity]
--- @param lighting LightingConfig
--- @param cursor_data CursorHandler
--- @param comment_system CommentSystem
--- @param rotary_inventory RotaryInventory
--- @return GameState
local function new_game(
	screen_size,
	screen_manager,
	player,
	entities,
	lighting,
	cursor_data,
	comment_system,
	rotary_inventory
)
	--- @class GameState
	--- @field screen_manager ScreenManager
	--- @field player Player
	--- @field entities [Entity]
	--- @field lighting LightingConfig
	--- @field mouse_pos userdata
	--- @field cursor_data CursorHandler
	--- @field comment_system CommentSystem
	--- @field rotary_inventory RotaryInventory
	local game = {
		screen_size = screen_size,
		screen_manager = screen_manager,
		player = player,
		entities = entities,
		lighting = lighting,
		cursor_data = cursor_data,
		comment_system = comment_system,
		rotary_inventory = rotary_inventory,
	}
	return game
end

-- Picotron hooks
function _init()
	window{cursor = 0}

	local screen_w,screen_h = get_display():attribs()

	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())

	local default_coltab = userdata("u8",64,64)
	default_coltab:peek(0x8000,0,64*64)
	local identity_coltab = userdata("u8",64,64)
	identity_coltab:peek(0x9000,0,64*64)

	local screen_manager = m_screen_manager.new(include"src/screen_data.lua","start")

	local player = m_player.new(
		screen_manager.screen.path,
		m_pathfinding.new_path_position(0.5,1)
	)

	local lighting = m_lighting.new(
		default_coltab,
		identity_coltab,
		get_spr(ILLUMINATION_CT_INDEX)
	)

	local cursor_data = m_cursor.new({
		go_to = {sprite = 128, pivot = vec(0,0)},
		interactable = {sprite = 129, pivot = vec(6,6)},
		interacting = {sprite = 130, pivot = vec(4,3)},
		examine = {sprite = 131, pivot = vec(9,6)},
	},"go_to")

	game = new_game(
		vec(screen_w,screen_h),
		screen_manager,
		player,
		{player.entity},
		lighting,
		cursor_data,
		m_comments.new(0.05,2),
		m_rotary_inventory.new(vec(0,screen_h),100)
	)
end

function _update()
	m_mouse.frame_start()
	
	m_mouse_handler.update(game)

	for entity in all(game.entities) do
		entity:animate(DT)
		entity:walk()
	end

	game.rotary_inventory:update()
	game.comment_system:advance_time(DT)
end

function _draw()
	cls()

	local screen = game.screen_manager.screen
	m_decorations.blit(screen.data.bg)
	for entity in all(game.entities) do
		m_entity_extensions.draw_lit(game.lighting,entity,screen.data.lighting)
	end
	m_decorations.spr(screen.data.fg)

	game.comment_system:draw_comments(game.screen_size)
	game.rotary_inventory:draw()
	game.cursor_data:draw(m_mouse.position())

	-- Debugging --
	if not DEBUG_MODE then return end

	print(string.format("CPU: %.2f%%",stat(1)*100),0,0,37)

	if key("x") then
		m_decorations.spr(screen.data.lighting)
	end
	
	if key("z") then
		get_display():bxor(get_display():band(0xC0):shr(2),true) -- Shows the high bits currently drawn to the screen
	end
end

include"src/error_explorer.lua"