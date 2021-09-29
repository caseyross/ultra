export default class CommentsStatistics

	constructor: (comments) ->
		@scoreRange = [0, 0]
		@computeStatistics(comments)

	computeStatistics: (comments) =>
		if comments?.length
			for comment in comments
				if comment.score < @scoreRange[0]
					@scoreRange[0] = comment.score
				else if comment.score > @scoreRange[1]
					@scoreRange[1] = comment.score
				@computeStatistics(comment.replies)