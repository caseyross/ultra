Object.defineProperty(String::, 'idType', {
	get: -> @.split(':')[0]
})

Object.defineProperty(String::, 'idSpecs', {
	get: -> @.split(':')[1..]
})

Object.defineProperty(String::, 'preHyphen', {
	get: -> @.split('-')[0]
})

Object.defineProperty(String::, 'postHyphen', {
	get: -> @.split('-')[1]
})

String::asId = (type) ->
	"#{type}:#{if @[2] == '_' then @[3..] else @}"

String::normalizedLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length

String::cColor = ->
	if not (@startsWith('#') and @length is 7)
		return '#000000'
	red = Number.parseInt(@[1..2], 16) / 255
	green = Number.parseInt(@[3..4], 16) / 255
	blue = Number.parseInt(@[5..6], 16) / 255
	if (green + red / 8 + blue / 8) > 0.9
		return '#000000'
	else
		return '#ffffff'