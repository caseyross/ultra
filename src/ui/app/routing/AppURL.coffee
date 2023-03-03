# Make reddit.com links relative instead of absolute so users can navigate seamlessly using our app.
export relativize_url = (url) ->
	url
		.toString()
		.replace(/^https?:\/\/redd\.it\/(?<path>[^"]*)/, '/p/$<path>')
		.replace(/^https?:\/\/(?:[A-Za-z]+\.)?reddit\.com\/(?<path>.*)/, '/$<path>')