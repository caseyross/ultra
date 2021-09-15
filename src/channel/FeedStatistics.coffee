export default class FeedStatistics

	constructor: (items) ->

		@largestScore = 0
		@computeStatistics(items)

	computeStatistics: (items) =>
		for item in items
			if Math.abs(item.score) > @largestScore
				@largestScore = Math.abs(item.score)