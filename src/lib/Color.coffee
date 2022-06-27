export default class Color

	constructor: (hex) ->
		@hex = hex

	asContrastHex: ->
		if not (@hex and @hex.startsWith('#') and @hex.length is 7)
			return '#000000'
		red = Number.parseInt(@hex[1..2], 16) / 255
		green = Number.parseInt(@hex[3..4], 16) / 255
		blue = Number.parseInt(@hex[5..6], 16) / 255
		if (red / 8 + green + blue / 8) > 1
			return '#000000'
		else
			return '#ffffff'