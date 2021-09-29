export default class FeedStatistics

	constructor: (items) ->
		@scoreRange = [0, 0]
		@computeStatistics(items)

	computeStatistics: (items) =>
		for item in items
			if item.score < @scoreRange[0]
				@scoreRange[0] = item.score
			else if item.score > @scoreRange[1]
				@scoreRange[1] = item.score