export default
	contrasting: (cssHexColor) ->
		if not (cssHexColor.startsWith '#' and cssHexColor.length is 7) then return 'inherit'
		red = Number.parseInt(cssHexColor[1..2], 16) / 255
		green = Number.parseInt(cssHexColor[3..4], 16) / 255
		blue = Number.parseInt(cssHexColor[5..6], 16) / 255
		if (green + red / 8 + blue / 8) > 0.7 then 'black' else 'white'
	heat: (heat) ->
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