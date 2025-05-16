local m_mouse = require("src/mouse")
local amath = require("src/amath")

local function update(self,dt)
	local last_angle = self.angle
	self.angle = self.angle+self.angle_per_frame
	if (sgn(last_angle%0.1-0.05) ~= sgn(self.angle%0.1-0.05)) then
		sfx(4)
		self.angle_per_frame = amath.move_toward(self.angle_per_frame,0,0.003)
		if abs(self.angle_per_frame) < 0.003 then
			self.angle_per_frame = 0
		end
	end
	self.angle %= 1
end

local function draw(self)
	local center = self.center

	-- Temporary
	circfill(center.x,center.y,self.radius,3)
	circ(center.x,center.y,self.radius,19)
	circfill(center.x,center.y,20,17)
	local norms = userdata("f64",2,4)
	norms:set(0,0,
		cos(self.angle),sin(self.angle),
		cos(self.angle+0.25),sin(self.angle+0.25),
		cos(self.angle+0.5),sin(self.angle+0.5),
		cos(self.angle+0.75),sin(self.angle+0.75)
	)
	local lines_start = (norms*20):add(center,true,0,0,2,0,2,4)
	local lines_end = (norms*self.radius):add(center,true,0,0,2,0,2,4)

	line(lines_start[0],lines_start[1],lines_end[0],lines_end[1],2)
	line(lines_start[2],lines_start[3],lines_end[2],lines_end[3],2)
	line(lines_start[4],lines_start[5],lines_end[4],lines_end[5],2)
	line(lines_start[6],lines_start[7],lines_end[6],lines_end[7],2)
end

local function inside(self,pos)
	return pos:distance(self.center) < self.radius
end

---@param self RotaryInventory
---@param event Event
local function on_event(self,event)
	if event.type == "hover" then
		event.output.cursor = "interactable"
	elseif event.type == "click_held" then
		event.output.consume_input = true
		event.output.cursor = "interacting"
		local pos,delta = m_mouse.position(),m_mouse.delta()
		local pos_from_center = pos-self.center
		local angle = atan2(pos_from_center.x,pos_from_center.y)

		local last_pos = pos-delta
		local last_pos_from_center = last_pos-self.center
		local last_angle = atan2(last_pos_from_center.x,last_pos_from_center.y)

		local angle_diff = angle-last_angle
		self.angle_per_frame = angle_diff
	end
end

--- Creates a new rotary inventory UI object.
--- @return RotaryInventory rotary_inventory The new rotary inventory object.
local function new(center,radius)
	--- @class RotaryInventory
	local inv = {
		center = center,
		radius = radius,
		angle = 0,
		angle_per_frame = 0,

		update = update,
		draw = draw,
		inside = inside,
		on_event = on_event,
	}

	return inv
end

return {
	new = new,
}