export default class Image
	constructor: (r) ->
		if r.status and r.status is not 'valid' # TODO: Add "error image" for unparseable images
			@aspect_ratio = 1
			@resolutions = [
				{
					height: 640
					width: 640
					url: ''
				}
			]
		else if r.p
			@aspect_ratio = r.s.x / r.s.y
			@resolutions = r.p.concat(r.s).map((resolution) ->
				height: resolution.y
				width: resolution.x
				url: resolution.u
			)
		else
			@aspect_ratio = r.source.width / r.source.height
			@resolutions = r.resolutions.concat(r.source).map((resolution) ->
				height: resolution.height
				width: resolution.width
				url: resolution.url
			)
		@resolutions.sort((a, b) -> a.width - b.width)
		@caption = r.caption ? ''
		@link = r.link ? ''
	best_fit: (target_width, target_height) =>
		@resolutions.fold(@resolutions[0], (current_best, next) ->
			if current_best.width < target_width and current_best.height < target_height
				return next
			return current_best
		)
	largest: () => @resolutions[@resolutions.length - 1]
				