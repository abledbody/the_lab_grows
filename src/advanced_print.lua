--- Advanced print function for printing multi-line text with alignment and outline options.
--- @param str string The string to print.
--- @param x number The x position to print the string at.
--- @param y number The y position to print the string at.
--- @param col integer? The color of the text.
--- @param pivot userdata The pivot point of the text block. (0,0) is top-left, (1,1) is bottom-right.
--- @param alignment "left"|"center"|"right" The alignment of the text in the block.
--- @param outline_col integer? The color of the outline.
--- @param screen_size userdata The size of the screen.
return function(str,x,y,col,pivot,alignment,outline_col,screen_size)
	local lines = str:split("\n")
	local sizes = userdata("f64",2,#lines)
	for i = 1,#lines do
		local line = lines[i]
		local width,height = print(line,0,-1000)
		sizes:set(0,i-1,width,height+1000)
	end

	local block_size = vec(0,0)
		:max(sizes,true,0,0,1,2,0,#lines)
		:add(sizes,true,1,1,1,2,0,#lines)
	
	if screen_size then
		x = mid(block_size.x*pivot.x,x,screen_size.x-block_size.x*(1-pivot.x))
		y = mid(block_size.y*pivot.y,y,screen_size.y-block_size.y*(1-pivot.y))
	end
	
	y = y-block_size.y*pivot.y
	x = x-block_size.x*pivot.x
	for i = 1,#lines do
		local line = lines[i]
		local size = sizes:row(i-1)

		local line_left_pad = alignment == "right" and block_size.x-size.x
			or alignment == "center" and (block_size.x-size.x)*0.5
			or 0
		
		if outline_col then
			--- @diagnostic disable-next-line: err-esc
			line = "\^o"..chr(151+outline_col).."ff"..line
		end
		
		--- @diagnostic disable-next-line: cast-local-type
		_,y = print(line,x+line_left_pad,y,col)
	end
end