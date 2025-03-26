--[[pod_format="raw",created="2024-04-18 05:27:43",modified="2025-03-26 03:33:04",revision=2370]]
include"require.lua"

dt = 1/60

local _cursor = require"_cursor"
local player = require"player"
local locations = require"locations"
local light_levels = require"light_levels"
local comment = require"comment"

function _init()
	locations.set_room(1,1)
	note(nil,0,32,nil,nil,10)
end

function _update()
	_cursor.update()
	player.update()
	comment.update()
end

function _draw()
	cls()
	locations.draw_bg()
	player.draw()
	locations.draw_objects()
	locations.draw_fg()
	comment.draw()
	_cursor.draw()
	--print(string.format("%.1f",stat(1)*100),0,0,37)
end

include("error_explorer.lua")