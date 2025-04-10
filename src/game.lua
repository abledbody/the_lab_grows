include"src/require.lua"

-- Dependencies
Animator = require"src/animation"

-- Constants
DT = 1/60
local ANIMATIONS <const> = fetch(DATP.."anm/0.anm")

-- Game state
local animator --- @class Animator

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())
	animator = Animator.new_animator(ANIMATIONS.idle)
end

function _update()
	animator:advance(DT)
end

function _draw()
	cls()
	spr(animator.sprite)
end

include"src/error_explorer.lua"