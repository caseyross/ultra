window.Statistics = 
	normalized_length: (s) ->
		x = encodeURI(s.replace(/<[^>]+>/g, ''))
		x.length - 2 * x.split('%').length