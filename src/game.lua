include"src/require.lua"

-- Dependencies
local m_player = require"src/player"
local m_pathfinding = require"src/pathfinding"
local m_clicking = require"src/clicking"
local m_screen_manager = require"src/screen_manager"
local m_lighting = require"src/lighting"
local m_entity_extensions = require"src/entity_extensions"
local m_decorations = require"src/decorations"
local m_cursor = require"src/cursor"
local m_screens = require"src/screens"

-- Constants
DT = 1/60
local DRAW_CPU <const> = true
local ILLUMINATION_CT_INDEX <const> = 191

-- Game state
local screen_manager --- @type ScreenManager
local player --- @type Player
local entities --- @type [Entity]
local lighting --- @type LightingConfig
local mouse_pos --- @type userdata
local cursor_data --- @type CursorHandler
local screen_getters --- @type ScreenScriptGetters

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())

	screen_manager = m_screen_manager.new(include"src/screen_data.lua","start")

	player = m_player.new(
		screen_manager.screen.path,m_pathfinding.new_path_position(0.5,1)
	)
	entities = {
		player.entity,
	}

	local default_coltab = userdata("u8",64,64)
	default_coltab:peek(0x8000,0,64*64)
	local identity_coltab = userdata("u8",64,64)
	identity_coltab:peek(0x9000,0,64*64)

	lighting = m_lighting.new(
		default_coltab,
		identity_coltab,
		get_spr(ILLUMINATION_CT_INDEX)
	)

	window{cursor = 0}

	cursor_data = m_cursor.new({
		go_to = {sprite = 128, pivot = vec(0,0)},
		interactable = {sprite = 129, pivot = vec(6,6)},
		interacting = {sprite = 130, pivot = vec(4,3)},
		examine = {sprite = 131, pivot = vec(9,6)},
	},"go_to")
end

function _update()
	local mx,my,mb = mouse()
	mouse_pos = vec(mx,my)
	m_clicking.frame_start(mb)
	local screen = screen_manager.screen
	
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

	for entity in all(entities) do
		entity:animate(DT)
		entity:walk()
	end
end

function _draw()
	cls()

	local screen = screen_manager.screen
	m_decorations.blit(screen.data.bg)
	for entity in all(entities) do
		m_entity_extensions.draw_lit(lighting,entity,screen.data.lighting)
	end
	m_decorations.spr(screen.data.fg)

	cursor_data:draw(mouse_pos)

	if DRAW_CPU then
		print(string.format("CPU: %.2f%%",stat(1)*100),0,0,37)
	end

	-- if key("z") then
	-- 	get_display():bxor(get_display():band(0xC0):shr(2),true) -- Shows the high bits currently drawn to the screen
	-- end
end

include"src/error_explorer.lua"