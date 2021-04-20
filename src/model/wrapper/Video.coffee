export default class Video
	constructor: (r) ->
		@width = r.width
		@height = r.height
		@tracks =
			if r.fallback_url # reddit hosted video
				audio: [
					new MediaSource {
						mime_type: 'audio/mp4'
						codec: 'mp4a.40.2'
						href: r.fallback_url.replaceAll(/DASH_[0-9]+/g, 'DASH_audio')
					}
				]
				video: [
					new MediaSource {
						mime_type: 'video/mp4'
						codec: 'avc1.4D401F' # 4D401E for 480p and below
						href: r.fallback_url
					}
				]
			else # GIF video
				audio: []
				video: [
					new MediaSource {
						mime_type: 'video/mp4'
						codec: 'avc1.4D401E' # probably
						href: r.url
					}
				]

class MediaSource
	constructor: ({ mime_type, codec, href }) ->
		@mime_type = mime_type
		@codec = codec
		@href = href