--- Draws an entity with lighting from an illuminance map.
--- @param self LightingConfig The lighting configuration to use.
--- @param entity Entity The entity to draw.
--- @param illuminance_map Decoration The illuminance map to use.
local function draw_lit(self,entity,illuminance_map)
	local sprite,size,pos,flipped = entity:unpack_entity_draw()

	self:draw_lit(
		function()
			sspr(
				sprite,
				0,0,size.x,size.y,
				pos.x,pos.y,nil,nil,
				flipped
			)
		end,
		illuminance_map,pos,size
	)
end

return {
	draw_lit = draw_lit,
}