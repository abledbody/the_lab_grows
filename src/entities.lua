--- @alias AnimationListener fun(self:Entity,frame_events:FrameEvents) A function that gets called when an animation event occurs.

local m_pathfinding = require"src/pathfinding"
local m_animation = require"src/animation"

--- Draws an entity.
--- @param self Entity The entity to draw.
local function draw(self)
	local sprite,size,pos,flipped = self:unpack_entity_draw()
	sspr(
		sprite,
		0,0,size.x,size.y,
		pos.x,pos.y,nil,nil,
		flipped
	)
end

--- Gets the necessary data to draw the entity.
--- @param self Entity The entity to unpack.
--- @return userdata sprite The sprite data.
--- @return userdata size The size of the sprite.
--- @return userdata pos The position of the sprite.
--- @return boolean flipped Whether the entity is flipped.
local function unpack_entity_draw(self)
	local sprite = get_spr(self.animator.sprite)
	local size = vec(sprite:width(),sprite:height() or 1)

	local pivot = self.animator.pivot
	pivot = self.flipped and vec(size.x-pivot.x, pivot.y) or pivot

	local pos = self.path_follower:get_world_position()-pivot
	
	return sprite,size,pos,self.flipped
end

--- Moves the entity along the path in time with the walk animation.
--- @param self Entity The entity to move.
local function walk(self)
	if self.animator.anim ~= self.animations.walk then return end
	
	self.flipped = self.path_follower:get_direction()

	local frame_advances = self.animator.frame_advances
	if frame_advances == 0 then return end
	
	self.path_follower:move_along(self.dist_per_walk_frame*frame_advances)
end

--- Selects an animation based on the entity's state or advances it in time.
--- @param self Entity The entity to animate.
--- @param dt number The amount of time to advance the animation.
local function animate(self,dt)
	local next_anim = self.path_follower:get_at_target() 
		and self.animations.idle
		or self.animations.walk
	
	if self.animator.anim == next_anim then
		self.animator:advance(dt)
	else
		self.animator.anim = next_anim
		self.animator:reset()
	end

	if self.animation_listener then
		for frame_events in all(self.animator.events) do
			self.animation_listener(self,frame_events)
		end
	end
end

--- Creates a new entity object.
--- @param path Path The path that the entity is spawned on.
--- @param path_pos PathPosition The position on the path that the entity is spawned at.
--- @param animations table<string,Animation> The animations for the entity.
--- @param dist_per_walk_frame number How many pixels the entity moves per walk animation frame.
--- @param animation_listener AnimationListener? The function to call when an animation event occurs.
--- @return Entity entity The new entity object.
local function new(path,path_pos,animations,dist_per_walk_frame,animation_listener)
	--- @class Entity Describes an animated object with pathfinding abilities.
	--- @field path_follower PathFollower The entity's path follower.
	--- @field animator Animator The entity's animator.
	--- @field flipped boolean Whether the entity is facing to the left.
	--- @field dist_per_walk_frame number How many pixels the entity moves per walk animation frame.
	--- @field animation_listener AnimationListener? The function to call when an animation event occurs.
	local entity = {
		path_follower = m_pathfinding.new_path_follower(path,path_pos),
		animations = animations,
		animator = m_animation.new_animator(animations.idle),
		flipped = false,
		dist_per_walk_frame = dist_per_walk_frame,
		animation_listener = animation_listener,
		unpack_entity_draw = unpack_entity_draw,
		draw = draw,
		walk = walk,
		animate = animate,
	}

	return entity
end

return {
	new = new,
}