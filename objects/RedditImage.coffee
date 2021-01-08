export default class RedditImage
	constructor: (raw) ->
		if raw.p
			@aspectRatio = raw.s.x / raw.s.y
			@versions = raw.p.concat(raw.s).map((resolution) ->
				height: resolution.y
				width: resolution.x
				url: resolution.u
			)
		else
			@aspectRatio = raw.source.width / raw.source.height
			@versions = raw.resolutions.concat(raw.source).map((resolution) ->
				height: resolution.height
				width: resolution.width
				url: resolution.url
			)
		@versions.sort((a, b) -> b.width - a.width)
	bestFit: (targetWidth, targetHeight) ->
		@versions.fold(versions[0], (currentBest, next) ->
			if currentBest.width < targetWidth and currentBest.height < targetHeight
				return next
			return currentBest
		)
			
				