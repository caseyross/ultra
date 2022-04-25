Object.defineProperty(String::, 'preHyphen', {
	get: -> @.split('-')[0]
})

Object.defineProperty(String::, 'postHyphen', {
	get: -> @.split('-')[1]
})

String::normalizedLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length