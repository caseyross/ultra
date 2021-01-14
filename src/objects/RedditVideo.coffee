import RedditImage from '/src/objects/RedditImage'

export default class RedditVideo
	constructor: (raw) ->
		@approximateLength = raw.media.reddit_video.duration
		@aspectRatio = raw.media.reddit_video.width / raw.media.reddit_video.height
		@coverImage = new RedditImage(raw.preview.images[0])
		@tracks =
			audio: [
				new RedditMediaSource('audio/mp4', 'mp4a.40.2', raw.url + '/DASH_audio.mp4')
			]
			video: ['96', '240', '360', '480', '720', '1080'].map((resolution) ->
				new RedditMediaSource('video/mp4', 'avc1.4D401F', raw.url + "/DASH_#{resolution}.mp4")
			)
		console.log raw, @

class RedditMediaSource
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