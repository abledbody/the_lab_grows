--- Draws an entity with lighting from an illuminance map.
--- @param self LightingConfig The lighting configuration to use.
--- @param entity Entity The entity to draw.
--- @param illuminance_map Decoration The illuminance map to use.
local function draw_lit(self,entity,illuminance_map)
	local sprite,pos,flipped,size = entity:unpack_entity_draw()

	self:draw_lit(
		function() spr(sprite,pos.x,pos.y,flipped) end,
		illuminance_map,pos,size
	)
end

return {
	draw_lit = draw_lit,
}