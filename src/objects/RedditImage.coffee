export default class RedditImage
	constructor: (raw) ->
		if raw.p
			@aspectRatio = raw.s.x / raw.s.y
			@resolutions = raw.p.concat(raw.s).map((resolution) ->
				height: resolution.y
				width: resolution.x
				url: resolution.u
			)
		else
			@aspectRatio = raw.source.width / raw.source.height
			@resolutions = raw.resolutions.concat(raw.source).map((resolution) ->
				height: resolution.height
				width: resolution.width
				url: resolution.url
			)
		@resolutions.sort((a, b) -> a.width - b.width)
		@caption = raw.caption ? ''
		@link = raw.link ? ''
	bestFit: (targetWidth, targetHeight) =>
		@resolutions.fold(@resolutions[0], (currentBest, next) ->
			if currentBest.width < targetWidth and currentBest.height < targetHeight
				return next
			return currentBest
		)
	largest: () => @resolutions[@resolutions.length - 1]
				