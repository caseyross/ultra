export default class RedditMoreComments
	constructor: (raw) ->
		@flags =
			scoreHidden: true
		@ids = raw.children
		@replies = []
		@stats =
			score: 0