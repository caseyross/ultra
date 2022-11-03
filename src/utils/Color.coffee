export default class Color

	constructor: (hex) ->
		@hex = hex

	asContrastHex: ->
		if not (@hex and @hex.startsWith('#') and @hex.length is 7)
			return 'currentcolor'
		red = Number.parseInt(@hex[1..2], 16) / 255
		green = Number.parseInt(@hex[3..4], 16) / 255
		blue = Number.parseInt(@hex[5..6], 16) / 255
		if (red / 3 + green + blue / 2) > 1
			return '#000000'
		else
			return '#ffffff'