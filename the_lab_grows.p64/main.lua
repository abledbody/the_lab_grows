--[[pod_format="raw",created="2025-04-03 22:54:12",modified="2025-04-09 19:06:11",revision=50]]
DATP = ""
if not fetch"src/game.lua" then
	cd("/projects/the_lab_grows")
	DATP = "the_lab_grows.p64/"
end
include"src/game.lua"