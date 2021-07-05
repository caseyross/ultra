export default Video = (d) ->
	if not d.fallback_url
		alert r
	@width = d.width
	@height = d.height
	@tracks =
		if d.fallback_url # reddit hosted video
			audio:
				if d.is_gif
					[]
				else
					[
						new MediaSource {
							mime_type: 'audio/mp4'
							codec: 'mp4a.40.2'
							href: d.fallback_url.replaceAll(/DASH_[0-9]+/g, 'DASH_audio')
						}
					]
			video: [
				new MediaSource {
					mime_type: 'video/mp4'
					codec: 'avc1.4D401F' # 4D401E for 480p and below
					href: d.fallback_url
				}
			]
		else # GIF video
			audio: []
			video: [
				new MediaSource {
					mime_type: 'video/mp4'
					codec: 'avc1.4D401E' # probably
					href: d.url
				}
			]

MediaSource = ({ mime_type, codec, href }) ->
	@mime_type = mime_type
	@codec = codec
	@href = href