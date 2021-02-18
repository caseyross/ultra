import Image from './Image'

export default class Video
	constructor: (r) ->
		@approximateLength = r.media.reddit_video.duration
		@aspect_ratio = r.media.reddit_video.width / r.media.reddit_video.height
		@coverImage = new Image(r.preview.images[0])
		@tracks =
			audio: [
				new MediaSource('audio/mp4', 'mp4a.40.2', r.url + '/DASH_audio.mp4')
			]
			video: ['96', '240', '360', '480', '720', '1080'].map((resolution) ->
				new MediaSource('video/mp4', 'avc1.4D401F', r.url + "/DASH_#{resolution}.mp4")
			)
		console.log r, @

class MediaSource
	constructor: (mimeType, codec, url) ->
		@mimeType = mimeType
		@codec = codec
		@url = url
		@fragments = [
			@nextFragment()
		]
	nextFragment: () =>
		fetch @url,
			method: 'GET'
			headers:
				'range': "bytes=#{0}-#{10000}"
		.then (response) -> console.log response.arrayBuffer()