export default class RedditMoreComments
	constructor: (raw) ->
		@ids = raw.children
		@replies = []