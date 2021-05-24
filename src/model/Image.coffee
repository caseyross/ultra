export default class Image
	constructor: (r) ->
		# NOTE: reddit only reports the true image height for the source image. The resized versions of the image have a height field, but it doesn't correspond to the actual height of the image.
		switch
			when r.status and not (r.status is 'valid')
				@aspect_ratio = 1
				@resolutions = [{
					width: 640
					href: '' # TODO: Add error image for invalid images
				}]
			when r.s
				@aspect_ratio = r.s.x / r.s.y
				@resolutions =
					if r.s.gif
						[{
							width: r.s.x
							href: r.s.gif
						}]
					else
						r.p.concat(r.s).map (resolution) ->
							width: resolution.x
							href: resolution.u
			when r.variants?.gif
				@aspect_ratio = r.variants.gif.source.width / r.variants.gif.source.height
				@resolutions =
					[{
						width: r.variants.gif.source.width
						href: r.variants.gif.source.url
					}]
			when r.source
				@aspect_ratio = r.source.width / r.source.height
				@resolutions = r.resolutions.concat(r.source).map (resolution) ->
					width: resolution.width
					href: resolution.url
			else
				@aspect_ratio = 1
				@resolutions = []
		@resolutions.sort (a, b) -> a.width - b.width
		@caption =
			if r.caption or r.link
				text: r.caption ? ''
				href: r.link ? ''
			else
				null
	resolve: ({ targetWidth = Infinity, targetHeight = Infinity, targetPixels = Infinity }) =>
		@resolutions.fold(
			@resolutions[0],
			(best, next) =>
				currentWidth = best.width
				currentHeight = best.width / @aspect_ratio
				currentPixels = best.width * best.width / @aspect_ratio 
				if currentWidth < targetWidth and currentHeight < targetHeight and currentPixels < targetPixels
					return next
				return best
		)