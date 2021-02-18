export default class MoreComments
	constructor: (r) ->
		@flags =
			scoreHidden: true
		@ids = r.children
		@replies = []
		@stats =
			score: 0