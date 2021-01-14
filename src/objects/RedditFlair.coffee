export default class RedditFlair
	constructor: (rawText, rawColor) ->
		if typeof rawText is 'string'
			@text = rawText?.replace(/:.+: /g, '').replace(/ :.+:/g, '').replace(/:.+:/g, ' ').trim()
		else
			@text = ''
		if typeof rawColor is 'string' and rawColor.length
			@color = rawColor
		else
			@color = 'gray'