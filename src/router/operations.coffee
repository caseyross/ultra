route = (url, options = { replace: false }) ->
	if options.replace
		history.replaceState(null, null, url)
	else
		history.pushState(null, null, url)

export listen = ->
	document.addEventListener('click',
		(event) ->
			if event.button is 0 and not (event.altKey or event.ctrlKey or event.metaKey) and event.target.tagName is 'A' and event.target.origin is origin
				route(new URL(event.target.href))
				event.preventDefault()
	)

export routeCurrentUrl = ->
	route(location, { replace: true })