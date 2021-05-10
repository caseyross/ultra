export default class Flair
	constructor: ({ text, color }) ->
		if typeof text is 'string'
			@text = text?.replace(/:.+: /g, '').replace(/ :.+:/g, '').replace(/:.+:/g, ' ').trim()
		else
			@text = ''
		if typeof color is 'string' and color.length
			@color = color
		else
			@color = 'gray'