Object.defineProperty(String::, 'idType', {
	get: -> @.split(':')[0]
})

Object.defineProperty(String::, 'idSpecs', {
	get: -> @.split(':')[1..]
})

Object.defineProperty(String::, 'isListingType', {
	get: -> @.idType.last == 'z'
})

Object.defineProperty(String::, 'last', {
	get: -> @.slice(-1)
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