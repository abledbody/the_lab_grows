include"src/require.lua"

-- Dependencies
Animator = require"src/animation"

-- Constants
DT = 1/60
local ANIM_IDLE <const> = Animator.by_rule(
	12,
	function(frame_i) return {
			duration = 0.2,
			sprite = frame_i-1,
	} end
)

-- Game state
local animator --- @class Animator

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())
	animator = Animator.new_animator(ANIM_IDLE)
end

function _update()
	animator:advance(DT)
end

function _draw()
	cls()
	spr(animator.sprite)
end

include"src/error_explorer.lua"