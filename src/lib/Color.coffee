export default class Color

	constructor: ({ hex }) ->
		switch
			when hex
				if hex.startsWith('#')
					hex = hex[1..]
				@r = (Number.parseInt(hex[0..1], 16) ? 255) / 255
				@g = (Number.parseInt(hex[2..3], 16) ? 255) / 255
				@b = (Number.parseInt(hex[4..5], 16) ? 255) / 255
			else
				@r = 1
				@g = 1
				@b = 1
	
	isDark: -> not @isLight()

	isLight: -> (@r / 4 + @g + @b / 3) > 1