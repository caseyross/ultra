export default class Image
	constructor: (r) ->
		@resolutions = switch
			when r.status and not (r.status is 'valid')
				[{
					width: 640
					height: 640
					href: '' # TODO: Add error image for invalid images
				}]
			when r.s
				if r.s.gif
					[{
						width: r.s.x
						height: r.s.y
						href: r.s.gif
					}]
				else
					r.p.concat(r.s).map (resolution) ->
						width: resolution.x
						height: resolution.y
						href: resolution.u
			when r.variants?.gif
				[{
					width: r.variants.gif.source.width
					height: r.variants.gif.source.height
					href: r.variants.gif.source.url
				}]
			when r.source
				r.resolutions.concat(r.source).map (resolution) ->
					width: resolution.width
					height: resolution.height
					href: resolution.url
			else
				[]
		@resolutions.sort (a, b) -> a.width - b.width
		@caption =
			text: r.caption ? ''
			href: r.link ? ''
	biggest: () => @resolutions.last()
	dimension_target: ({ width, height }) =>
		@resolutions.fold(@resolutions[0], (best, next) ->
			if best.width < width and best.height < height
				return next
			return best
		)
				