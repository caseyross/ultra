export default
	normalizedLength: (htmlString) ->
		x = encodeURI(htmlString.replace(/<[^>]+>/g, ''))
		return x.length - 2 * x.split('%').length