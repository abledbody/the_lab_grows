--- @alias Node userdata A 2-element f64 vector representing a 2D point in space.
--- @alias Edge userdata A 2-element i32 vector holding the indices of the two nodes that the edge connects.
--- @alias Junction [integer] An array where each index corresponds to a node and each value is a list of indices corresponding to edges connected to that node.
--- @alias Traversal [{increasing: boolean, edge_i: integer}] A sequence of edge indices and traversal directions that connect two PathPositions.

--- Gets the worldspace coordinates of a PathPosition.
--- @param self PathPosition The PathPosition to get the worldspace coordinates of.
--- @param path Path The path that the PathPosition is on.
--- @return userdata world_position The worldspace coordinates of the PathPosition.
local function path_to_world_position(self,path)
	local edge = path.edges[self.edge_i]
	assert(edge,"Path does not have an edge at index "..self.edge_i)
	local n1,n2 = path.nodes[edge[0]],path.nodes[edge[1]]
	return (n2-n1)*self.t+n1
end

local c_path_position = {
	--- Compares two PathPositions for equality.
	--- @param a PathPosition The first PathPosition.
	--- @param b PathPosition The second PathPosition.
	--- @return boolean #Whether the two PathPositions represent the same position on the path.
	__eq = function(a,b) return a.t == b.t and a.edge_i == b.edge_i end,
}

--- Creates a new PathPosition from the interpolant and edge index provided.
--- @param t number The normalized interpolant between the two nodes that the edge connects.
--- @param edge_i integer The index of the edge in the path.
--- @return PathPosition path_position The new PathPosition.
local function new_path_position(t,edge_i)
	--- @class PathPosition Represents a position on a path via an edge index and a normalized interpolant.
	--- @field t number The normalized interpolant between the two nodes that the edge connects.
	--- @field edge_i integer The index of the edge in the path.
	local pos = {
		t = t,
		edge_i = edge_i,
		world_position = path_to_world_position,
	}
	return setmetatable(pos,c_path_position)
end

--- Creates a cache of all the edges that are connected to each node in the path.
--- This is used to speed up the pathfinding process by avoiding the need to
--- search through all the edges to find one that connects to a given node.
--- If the path changes, the cache is invalid, and should be rebuilt.
--- @param edges [Edge] The edges in the path
--- @return [Junction] junctions The resulting list of junctions, one for each node, in corresponding order.
local function cache_junctions(edges)
	local junctions = {}
	for i,edge in ipairs(edges) do
		local n1,n2 = edge[0],edge[1]
		junctions[n1] = junctions[n1] or {}
		junctions[n2] = junctions[n2] or {}
		add(junctions[n1],i)
		add(junctions[n2],i)
	end
	return junctions
end

--- Creates a cache of the lengths of all the edges in the path.
--- If the path changes, the cache is invalid, and should be rebuilt.
--- @param nodes [Node] The nodes in the path.
--- @param edges [Edge] The edges in the path.
--- @return [number] lengths The resulting list of edge lengths, in corresponding order.
local function cache_lengths(nodes,edges)
	local lengths = {}
	for i,edge in ipairs(edges) do
		local n1,n2 = nodes[edge[0]],nodes[edge[1]]

		if not (n1 and n2) then
			local err = ""
			if not n1 then err = "Low side of edge "..i.." refers to nonexistent node "..edge[0] end
			if not n2 then
				if err ~= "" then err = err.."\n" end
				err = err.."High side of edge "..i.." refers to nonexistent node "..edge[1]
			end
			error(err)
		end

		lengths[i] = (n2-n1):magnitude()
	end
	return lengths
end

--- Generates a sequence of edge indices and traversal directions that connect
--- two PathPositions using an A* pathfinding algorithm.
--- @param self Path The path to traverse.
--- @param from PathPosition The starting position.
--- @param to PathPosition The target position.
--- @param max_distance number? The maximum distance to search for a path.
--- @return Traversal? traversal The sequence of edge indices and traversal directions that connect the two positions. `nil` if there is no valid path.
local function traverse(self,from,to,max_distance)
	-- No need to pathfind if the two positions are on the same edge.
	if from.edge_i == to.edge_i then
		return {{
			increasing = from.t < to.t,
			edge_i = from.edge_i,
		}}
	end

	max_distance = max_distance or math.huge
	local nodes,edges = self.nodes,self.edges
	local junctions,edge_lengths = self.junctions,self.edge_lengths
	local p_from,p_to = from:world_position(self),to:world_position(self)
	local edge = edges[from.edge_i]
	
	local function first_node(i)
		local travel = (nodes[i]-p_from):magnitude()
		local gap = (p_to-nodes[i]):magnitude()
		return {
			i = i,edge_i = from.edge_i,
			travel = travel,gap = gap,
			par = travel+gap
		}
	end
	
	-- Every node that could potentially yield a shorter path
	-- than the current best.
	local open = {first_node(edge[0]),first_node(edge[1])}
	-- Every node that has already been checked. This is a hashset, because
	-- we only ever want to know if a node has been closed, not its actual
	-- data. Values are true, keys are the node indices.
	local closed = {}

	-- If there's no more nodes to search, the function will just end without
	-- returning anything, indicating that it failed to find a path.
	while #open > 0 do
		-- The best node is the one with the smallest par, or, if there is more
		-- than one node with the smallest par, the one with the smallest gap.
		local sample,sample_i = open[1],1
		for i = 2,#open do
			if open[i].par < sample.par
				or (open[i].par == sample.par and open[i].gap < sample.gap)
			then
				sample,sample_i = open[i],i
			end
		end
		-- This node is the one we're going to search the neighbors of,
		-- so we'll move it from the open list to the closed list.
		closed[deli(open,sample_i).i] = true

		for edge_i in all(junctions[sample.i]) do
			edge = edges[edge_i]
			-- If we find the target edge among the list of neighbors, then we
			-- have a valid path, and can start building the Traversal.
			if edge_i == to.edge_i then
				-- If the node we're coming from is the start of the edge, then
				-- you need to increase t to approach the target.

				-- Note that this, the last edge in the list, goes forward from
				-- this node, whereas every other edge goes backwards from its
				-- respective node. That's why the equality comparisons for
				-- direction don't match.
				local traversal = {{
					increasing = sample.i == edge[0],
					edge_i = edge_i,
				}}

				while sample do
					edge_i = sample.edge_i
					edge = edges[edge_i]
					add(traversal,{
						increasing = sample.i ~= edge[0],
						edge_i = edge_i,
					},1)
					sample = sample.parent
				end

				return traversal
			end

			local neighbor_i = edge[0] == sample.i and edge[1] or edge[0]

			-- Raptor attack!
			if closed[neighbor_i] then goto next_neighbor end
			
			local neighbor = {}
			neighbor.travel = sample.travel+edge_lengths[edge_i]
			neighbor.gap = (p_to-nodes[neighbor_i]):magnitude()
			neighbor.par = neighbor.travel+neighbor.gap
			neighbor.i = neighbor_i
			neighbor.edge_i = edge_i
			neighbor.parent = sample
			
			local existing_open,existing_open_i = nil,nil
			for i,open_node in ipairs(open) do
				if open_node.i == neighbor_i then
					existing_open,existing_open_i = open_node,i
					break
				end
			end
			
			if existing_open then
				if neighbor.par >= existing_open.par
					or neighbor.travel > max_distance
				then goto next_neighbor end
				
				open[existing_open_i] = neighbor
			else
				add(open,neighbor)
			end

			::next_neighbor::
		end
	end
end

--- Finds the closest PathPosition to a given worldspace position.
--- @param self Path The path to search.
--- @param pos userdata The worldspace position to find the closest PathPosition to.
--- @return PathPosition path_position The closest PathPosition to the given position. `nil` if the path is empty.
local function find_closest_path_position(self,pos)
	local nodes,edges = self.nodes,self.edges

	-- We can be sure that if self is a valid path, edges is not empty, so this
	-- will always result in a valid PathPosition, despite the nil initialization.
	local closest_path_pos = nil --- @type PathPosition
	local closest_dist = math.huge

	for i,edge in ipairs(edges) do
		local n1,n2 = nodes[edge[0]],nodes[edge[1]]
		local delta = n2-n1
		local length = delta:magnitude()

		-- Nesting's a little faster than goto, and it's not too deep.
		if length ~= 0 then
			local dir = delta/length

			local scalar_projection = (pos-n1):dot(dir)
			if scalar_projection < 0 then scalar_projection = 0 end
			if scalar_projection > length then scalar_projection = length end

			local projection = dir*scalar_projection+n1
			local rejection = pos-projection

			local dist = rejection:magnitude()
			if dist < closest_dist then
				closest_path_pos = new_path_position(scalar_projection/length,i)
				closest_dist = dist
			end
		end
	end

	return closest_path_pos
end


--- Creates a new path from the nodes and edges provided.
--- @param nodes [Node] The nodes in the path.
--- @param edges [Edge] The edges in the path.
--- @return Path path The new path.
local function new_path(nodes,edges)
	if #nodes < 2 or #edges < 1 then
		error("At least 2 nodes and 1 edge are required to create a path.")
	end

	--- @class Path A distributed graph of nodes and edges in euclidean space.
	--- @field nodes [Node] An array of 2D f64 vectors representing the nodes in the path.
	--- @field edges [Edge] An array of 2D i32 vectors with the indices of the two nodes that the edge connects.
	--- @field junctions [Junction] An array where each index corresponds to a node and each value is a list of indices corresponding to nodes that share an edge.
	--- @field edge_lengths [number] An array where each index corresponds to an edge and each value is the length of the edge.
	local path = {
		nodes = nodes,
		edges = edges,
		junctions = cache_junctions(edges),
		edge_lengths = cache_lengths(nodes,edges),

		traverse = traverse,
		find_closest_path_position = find_closest_path_position,
	}
	return path
end

--- Recalculates the traversal to go from the current position to the target.
--- @param self PathFollower The PathFollower to set the target for.
--- @param target PathPosition The target position on the path.
local function set_target(self,target)
	self.target = target
	self.traversal = self.path:traverse(self.path_position,target)
	self.step = 1
end

--- Moves the PathFollower along the path by a given distance, stopping at the
--- target position if the distance would go beyond it.
--- @param self PathFollower The PathFollower to move along the path.
--- @param distance number The distance to move along the path.
--- @return boolean moved Whether the PathFollower has moved along the path.
local function move_along(self,distance)
	local traversal = self.traversal
	local path_pos,target = self.path_position,self.target
	if not traversal or distance <= 0 or path_pos == target then return false end
	
	local step,edge_lengths = self.step,self.path.edge_lengths

	local leg = traversal[step]
	local edge_len = edge_lengths[path_pos.edge_i]

	-- t is normalized, extent is worldspace. To avoid iterative transformations,
	-- everything is done with extents, and then normalized at the end.
	local extent = path_pos.t*edge_len+(leg.increasing and distance or -distance)
	while true do
		-- If we're on the final leg, we're definitely not going to advance
		-- again, and the target is guaranteed to be here.
		if step >= #traversal then
			-- Clamp the t value to never go beyond the target.
			local target_extent = target.t*edge_len
			if leg.increasing == (extent > target_extent) then
				extent = target_extent
			end
			break
		end

		-- If we're inside the bounds of the edge, we aren't going to be in the
		-- next edge, so we can stop advancing.
		if extent >= 0 and extent <= edge_len then break end

		-- We'll have to check the next leg, so we'll advance the step, and
		-- the rest of the data that goes with it.
		step += 1

		-- Effectively, we are removing the portion of the last leg that was
		-- covered, and then moving the extent to the start of the next leg.
		local overshoot = extent < 0 and -extent or extent-edge_len
		leg = traversal[step]
		edge_len = edge_lengths[leg.edge_i]
		extent = leg.increasing and overshoot or edge_len-overshoot
	end

	self.step = step
	self.path_position =
		new_path_position(edge_len == 0 and 0 or extent/edge_len,leg.edge_i)
	
	return true
end

--- Gets the world position of the PathFollower from its path position.
---@param self PathFollower The PathFollower to get the world position of.
---@return userdata world_position The world position of the PathFollower.
local function get_world_position(self)
	return self.path_position:world_position(self.path)
end

--- Checks if the PathFollower has reached its target position.
--- @param self PathFollower The PathFollower to check the target position of.
--- @return boolean at_target Whether the PathFollower has reached its target position.
local function get_at_target(self)
	return self.path_position == self.target
end

--- Checks if the PathFollower is moving in the positive direction of each axis.
--- @param self PathFollower The PathFollower to check the direction of.
--- @return boolean positive_x Whether the PathFollower is moving in the positive direction of the x axis.
--- @return boolean positive_y Whether the PathFollower is moving in the positive direction of the y axis.
local function get_direction(self)
	local traversal_step = self.traversal[self.step]
	local nodes = self.path.nodes

	local edge = self.path.edges[traversal_step.edge_i]
	local delta = nodes[edge[1]]-nodes[edge[0]]

	return delta.x < 0 == traversal_step.increasing,
		delta.y < 0 == traversal_step.increasing
end

--- Creates a new PathFollower
--- @param path Path The path that the PathFollower is following.
--- @param path_position PathPosition The starting position on the path.
--- @return PathFollower path_follower The new PathFollower.
local function new_path_follower(path,path_position)
	--- @class PathFollower Manages state for picking a path traversal and gradually following it over time.
	--- @field path Path The path that the PathFollower is following.
	--- @field path_position PathPosition The current position on the path.
	--- @field target PathPosition The target position on the path.
	--- @field traversal Traversal? The steps that need to be traversed to reach the target.
	--- @field step integer The current step in the traversal.
	local path_follower = {
		path_position = path_position,
		path = path,
		target = path_position,
		step = 1,
		
		move_along = move_along,
		set_target = set_target,
		get_world_position = get_world_position,
		get_at_target = get_at_target,
		get_direction = get_direction,
	}
	return path_follower
end

return {
	new_path = new_path,
	new_path_position = new_path_position,
	new_path_follower = new_path_follower,
}