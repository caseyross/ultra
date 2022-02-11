# NOTE:
# Reddit only reports a reliable image height for the source image of a series. The reported height for resized images is generally incorrect.
# Thus, we need to determine the resized image heights ourselves.
export class Image
	constructor: (d) ->
		switch
			when d.status and not (d.status is 'valid')
				@aspect = 1
				@sizes = [{
					w: 640
					u: '' # TODO: Add error image for invalid images
				}]
			when d.s
				@aspect = d.s.x / d.s.y
				@sizes =
					if d.s.gif
						[{
							w: d.s.x
							u: d.s.gif
						}]
					else
						d.p.concat(d.s).map (resolution) ->
							w: resolution.x
							u: resolution.u
			when d.variants?.gif
				@aspect = d.variants.gif.source.width / d.variants.gif.source.height
				@sizes =
					[{
						w: d.variants.gif.source.width
						u: d.variants.gif.source.url
					}]
			when d.source
				@aspect = d.source.width / d.source.height
				@sizes = d.resolutions.concat(d.source).map (resolution) ->
					w: resolution.width
					u: resolution.url
			else
				@aspect = 1
				@sizes = []
		@sizes.sort (a, b) -> a.w - b.w
		for s in @sizes
			s.h = s.w / @aspect
		@caption =
			if d.caption or d.link
				t: d.caption ? ''
				u: d.link ? ''
			else
				null
	pick: ({ minH, minW, maxH, maxW, maxP }) =>
		@sizes.fold(
			@sizes[0],
			(a, b) => switch
				when a.w < minW then b
				when a.h < minH then b
				when a.w >= maxW then a
				when a.h >= maxH then a
				when a.w * a.h > maxP then a
				else b
		)