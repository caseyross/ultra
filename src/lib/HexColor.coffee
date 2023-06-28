export default {

	contrast: (color) ->
		if color.startsWith('#')
			color = color[1..]
		R = (Number.parseInt(color[0..1], 16) ? 255) / 255
		G = (Number.parseInt(color[2..3], 16) ? 255) / 255
		B = (Number.parseInt(color[4..5], 16) ? 255) / 255
		if (0.25 * R + 1.125 * G + 0.0 * B) > 1 # yes, blue component counts for 0
			return '#000000'
		else
			return '#ffffff'

}