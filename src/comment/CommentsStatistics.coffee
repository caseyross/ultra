export default class CommentsStatistics

	constructor: (comments) ->

		@largestScore = 0
		@computeStatistics(comments)

	computeStatistics: (comments) =>
		if comments?.length
			for comment in comments
				if Math.abs(comment.score) > @largestScore
					@largestScore = Math.abs(comment.score)
				@computeStatistics(comment.replies)