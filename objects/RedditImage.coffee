export default class RedditImage
	constructor: (raw) ->
		image =
			clear: [...rawImage.resolutions, rawImage.source].map
			blur: rawImage.map