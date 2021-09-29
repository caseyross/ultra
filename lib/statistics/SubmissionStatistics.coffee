export default class SubmissionStatistics

	constructor: (submissions) ->
		@scoreRange = [0, 0]
		@computeStatistics(submissions)

	computeStatistics: (submissions) =>
		if submissions?.length
			for submission in submissions
				if submission.score < @scoreRange[0]
					@scoreRange[0] = submission.score
				else if comment.score > @scoreRange[1]
					@scoreRange[1] = item.score
				@computeStatistics(comment.replies)