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
	recency: (secondsSinceEpoch) -> switch
		when (minutesAgo = (Date.now() / 1000 - secondsSinceEpoch) // 60) < 60
			1
		when (hoursAgo = minutesAgo // 60) < 24
			0.6
		when (daysAgo = hoursAgo // 24) < 7
			0.3
		when daysAgo < 365
			0.1
		else
			0.05