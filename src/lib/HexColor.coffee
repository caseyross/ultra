HexColor = {

	contrasting: (color) ->
		if HexColor.lightness(color) > 0.5
			'#000000'
		else
			'#ffffff'

	lightness: (color) ->
		{ R, G, B } = HexColor.rgb(color)
		return 0.1 * R + 0.6 * G + 0.0 * B # yes, blue component counts for 0

	rgb: (color) ->
		if color.startsWith('#')
			color = color[1..]
		R = (Number.parseInt(color[0..1], 16) ? 255) / 255
		G = (Number.parseInt(color[2..3], 16) ? 255) / 255
		B = (Number.parseInt(color[4..5], 16) ? 255) / 255
		return { R, G, B }

}

export default HexColor