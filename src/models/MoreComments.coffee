export default class MoreComments
	constructor: (r) ->
		@ids = r.children
		@meta =
			score: NaN