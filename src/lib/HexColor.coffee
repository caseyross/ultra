HexColor = {

	# This is scaled so that 0.5 is approximately the switchover point between black or white text providing better contrast on the given color.
	# i.e.:
	# - value between 0--0.5, use white text.
	# - value between 0.5--0.75, use black text.
	#
	# Max value is 0.75.
	lightness: (color) ->
		{ R, G, B } = HexColor.rgb(color)
		return 0.1 * R + 0.6 * G + 0.05 * B

	rgb: (color) ->
		if color.startsWith('#')
			color = color[1..]
		R = (Number.parseInt(color[0..1], 16) ? 255) / 255
		G = (Number.parseInt(color[2..3], 16) ? 255) / 255
		B = (Number.parseInt(color[4..5], 16) ? 255) / 255
		return { R, G, B }

}

export default HexColor