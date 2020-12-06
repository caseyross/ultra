export default class Comment
	constructor: (raw) ->
		@id = raw.id
		@body = raw.body