export class DatasetID

	constructor: (type, ...components) ->
		if components.length == 0 then [type, ...components] = type.split(':')
		@type = type.toLowerCase()
		@components = components.map((c) -> c.toLowerCase().replace(/^t[1-6]_/, ''))

	isSameAs: (id) ->
		id instanceof DatasetID and id.toString() == @toString() 

	toString: ->
		@type + ':' + @components.join(':')

Object.defineProperty(DatasetID::, 'isListingType', {
	get: -> @type.slice(-1) == 'z'
})