export default class Image
	constructor: (r) -> # TODO: fix gifs
		if r.status and r.status is not 'valid' # TODO: Add "error image" for unparseable images
			@aspect_ratio = 1
			@resolutions = [
				{
					width: 640
					height: 640
					href: ''
				}
			]
		else if r.p
			@aspect_ratio = r.s.x / r.s.y
			@resolutions = r.p.concat(r.s).map((resolution) ->
				width: resolution.x
				height: resolution.y
				href: resolution.u
			)
		else
			@aspect_ratio = r.source.width / r.source.height
			@resolutions = r.resolutions.concat(r.source).map((resolution) ->
				width: resolution.width
				height: resolution.height
				href: resolution.url
			)
		@resolutions.sort((a, b) -> a.width - b.width)
		@caption =
			text: r.caption ? ''
			href: r.link ? ''
	best_fit: (target_width, target_height) =>
		@resolutions.fold(@resolutions[0], (current_best, next) ->
			if current_best.width < target_width and current_best.height < target_height
				return next
			return current_best
		)
	largest: () => @resolutions[@resolutions.length - 1]
				