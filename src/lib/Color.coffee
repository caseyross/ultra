window.Color =
	contrasting: (s) ->
		if not (s.startsWith('#') and s.length is 7) then 'inherit'
		red = Number.parseInt(s[1..2], 16) / 255
		green = Number.parseInt(s[3..4], 16) / 255
		blue = Number.parseInt(s[5..6], 16) / 255
		if (green + red / 8 + blue / 8) > 0.9 then 'black' else 'white'