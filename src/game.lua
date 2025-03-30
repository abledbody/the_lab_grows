include"src/require.lua"

-- Dependencies
Animator = require"src/animation"
Pathfinding = require"src/pathfinding"

-- Constants
DT = 1/60

local PATH_DEF <const> = {
	nodes = {
		vec(10,10),
		vec(470,10),
		vec(470,260),
		vec(10,260),
		vec(240,135),
		vec(240,40),
		vec(355,72),
		vec(355,135),
	},
	edges = {
		vec(1,5),
		vec(2,7),
		vec(7,5),
		vec(7,8),
		vec(3,5),
		vec(4,5),
		vec(1,4),
		vec(1,6),
		vec(6,2),
		vec(6,5),
	},
}

-- Game state
local path --- @type Path
local path_follower --- @type PathFollower
local last_mouse_buttons --- @type integer

-- Picotron hooks
function _init()
	poke4(0x5000, fetch(DATP.."pal/0.pal"):get())
	path = Pathfinding.new_path(PATH_DEF.nodes,PATH_DEF.edges)
	path_follower = Pathfinding.new_path_follower(
		path,
		Pathfinding.new_path_position(0,1)
	)
	_,_,last_mouse_buttons = mouse()
end

function _update()
	local mx,my,mb = mouse()
	local mouse_pos = vec(mx,my)
	if (mb&~last_mouse_buttons)&1 ~= 0 then
		path_follower:set_target(
			path:find_closest_path_position(mouse_pos)
		)
	end
	path_follower:move_along(100*DT)
	last_mouse_buttons = mb
end

function _draw()
	cls()

	for i = 1,#path.edges do
		local edge = path.edges[i]
		local a = path.nodes[edge[0]]
		local b = path.nodes[edge[1]]
		line(a.x,a.y,b.x,b.y,37)
	end

	local traversal = path_follower.traversal
	if traversal then
		for i = 1,#traversal do
			local edge = path.edges[traversal[i].edge_i]
			local n1,n2 = path.nodes[edge[0]],path.nodes[edge[1]]
			line(n1.x,n1.y,n2.x,n2.y,42)
		end
	end

	local pos = path_follower.path_position:world_position(path)
	circfill(pos.x,pos.y,4,4)

	local target_pos = path_follower.target:world_position(path)
	line(target_pos.x-4,target_pos.y,target_pos.x+4,target_pos.y,62)
	line(target_pos.x,target_pos.y-4,target_pos.x,target_pos.y+4,62)
end

include"src/error_explorer.lua"