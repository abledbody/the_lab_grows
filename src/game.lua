include"src/require.lua"

-- Dependencies
local animation = require"src/animation"
local screens = require"src/screens"

-- Constants
DT = 1/60
local ANIMATIONS <const> = fetch(DATP.."anm/0.anm")
local DRAW_CPU <const> = true

-- Game state
local animator --- @class Animator
local screen_key --- @type string

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())
	animator = animation.new_animator(ANIMATIONS.idle)
	screen_key = "start"
end

function _update()
	animator:advance(DT)
end

function _draw()
	cls()

	local screen = screens.screens[screen_key]
	screen:draw_bg()
	spr(animator.sprite,52,139)
	screen:draw_fg()

	if DRAW_CPU then
		print(string.format("CPU: %.2f%%",stat(1)*100),0,0,37)
	end
end

include"src/error_explorer.lua"