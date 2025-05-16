local function move_toward(from,to,step)
	local diff = to-from
	if abs(diff) < step then return to end
	return from+sgn(diff)*step
end

return {
	move_toward = move_toward,
}