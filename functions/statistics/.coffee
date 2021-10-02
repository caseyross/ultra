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

(items) ->
	items.fold(
		{
			score:
				low: 
				high: 
		},
		(stats, item) ->
			if item.score < stats.score.low
				stats.score.low = item.score
			else if item.score > stats.score.high
				stats.score.high = item.score
			return stats