export default class RedditUser
	constructor: (name) ->
		if name
			@id = '/u/' + name
		else
			@id = ''
		@name = @id[3..]