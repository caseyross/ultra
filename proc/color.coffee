export contrast_color = (css_hex_color) ->
	if not (css_hex_color.startsWith('#') and css_hex_color.length is 7) then return 'inherit'
	red = Number.parseInt(css_hex_color[1..2], 16) / 255
	green = Number.parseInt(css_hex_color[3..4], 16) / 255
	blue = Number.parseInt(css_hex_color[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.7 then 'black' else 'white'

export heat_color = (heat) ->
	switch
		when heat > 2
			'salmon'
		when heat > 2
			'lightsalmon'
		when heat > 2
			'wheat'
		when heat > 2
			'white'
		when heat > 2
			'#ccc'
		else
			'gray'