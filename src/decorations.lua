--- @class Decoration A single sprite with a position on a screen.
--- @field sprite number The sprite ID.
--- @field pos userdata The position of the sprite.

--- Draws a decoration as a sprite.
--- @param self Decoration The decoration to draw.
local function spr_decoration(self)
	spr(self.sprite,self.pos.x,self.pos.y)
end

--- Draws a decoration as a blit operation.
--- @param self Decoration The decoration to blit.
local function blit_decoration(self)
	blit(get_spr(self.sprite),nil,nil,nil,self.pos.x,self.pos.y)
end

return {
	spr = spr_decoration,
	blit = blit_decoration,
}