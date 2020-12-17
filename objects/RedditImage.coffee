export default class RedditImage
	constructor: (raw) ->
		if raw.p
			@ratio = raw.s.x / raw.s.y
			@sizes = raw.p.concat(raw.s).map((resolution) ->
				width: resolution.x
				url: resolution.u
			)
		else
			@ratio = raw.source.width / raw.source.height
			@sizes = raw.resolutions.concat(raw.source).map((resolution) ->
				width: resolution.width
				url: resolution.url
			)