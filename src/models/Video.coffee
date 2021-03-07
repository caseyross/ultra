export default class Video
	constructor: (r) ->
		@width = r.width
		@height = r.height
		@tracks =
			audio: [
				new MediaSource({
					mime_type: 'audio/mp4',
					codec: 'mp4a.40.2'
					href: r.fallback_url.replaceAll('DASH_' + @height, 'DASH_audio')
				})
			]
			video: [
				new MediaSource({
					mime_type: 'video/mp4',
					codec: 'avc1.4D401F' # 4D401E for 480p and below
					href: r.fallback_url
				})
			]

class MediaSource
	constructor: ({ mime_type, codec, href }) ->
		@mime_type = mime_type
		@codec = codec
		@href = href