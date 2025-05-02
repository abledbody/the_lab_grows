local m_decorations = require"src/decorations"

--- Adds lighting to the provided draw call.
--- @param self LightingConfig The lighting configuration to use.
--- @param draw_call function The draw call to add lighting to.
--- @param illuminance_map Decoration The illuminance map to use.
--- @param pos userdata The position of the illuminance overlay.
--- @param size userdata The size of the illuminance overlay.
local function draw_lit(self,draw_call,illuminance_map,pos,size)
	poke(0x5509,0x7F) -- Write to the first mask bit
	draw_call()
	poke(0x5509,0x3F)

	poke(0x550A,0x7F) -- Read from the first mask bit
	self.identity_coltab:poke(0x8000) -- If first mask bit is not set, do nothing.
	self.illuminance_coltab:poke(0x9000) -- If first mask bit is set, illuminate.
	clip(pos.x,pos.y,size.x,size.y) -- Clip to the size of the sprite

	m_decorations.spr(illuminance_map)

	-- Reset the important stuff.
	clip()
	self.default_coltab:poke(0x8000)
	poke(0x550A,0x3F)
end

--- Creates a lighting configuration.
--- @param default_coltab userdata The default color table.
--- @param identity_coltab userdata The identity color table. (All transparent)
--- @param illuminance_coltab userdata The illuminance color table.
--- @return LightingConfig lighting The new lighting configuration.
local function new(default_coltab,identity_coltab,illuminance_coltab)
	--- @class LightingConfig Holds on to relevant color tables for lighting effects.
	--- @field default_coltab userdata The default color table.
	--- @field identity_coltab userdata The identity color table. (All transparent)
	--- @field illuminance_coltab userdata The illuminance color table.
	local lighting = {
		default_coltab = default_coltab,
		identity_coltab = identity_coltab,
		illuminance_coltab = illuminance_coltab,
		draw_lit = draw_lit,
	}
	return lighting
end

return {
	new = new,
}