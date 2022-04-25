String::normalizedLength = ->
	x = encodeURI(@replace(/<[^>]+>/g, ''))
	x.length - 2 * x.split('%').length