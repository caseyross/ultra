routes = {}
rewrites = {}

route = (url, options = { replace: false }) ->
	# 1. "Navigate"
	if options.replace then history.replaceState(null, null, url) else history.pushState(null, null, url)
	# 2. Rewrite URL, if applicable
	if rewrites[url] then history.replaceState(null, null, rewrites[url])
	# 3. Compute page data for route
	page = routes[url] ? {}
	announce(page)
	return page

watchers = []

announce = (page) ->
	for callback in watchers then callback(page)
	return watchers.length

export init = (routeMap, rewriteMap) ->
	routes = routeMap
	rewrites = rewriteMap
	document.addEventListener('click',
		(event) ->
			if event.button is 0 and not (event.altKey or event.ctrlKey or event.metaKey or event.shiftKey) and event.target.tagName is 'A' and event.target.origin is origin
				route(new URL(event.target.href))
				event.preventDefault())
	document.addEventListener('keydown',
		(event) ->
			if event.key is 'Enter' and not (event.altKey or event.ctrlKey or event.metaKey or event.shiftKey) and event.target.tagName is 'A' and event.target.origin is origin
				route(new URL(event.target.href))
				event.preventDefault())

export routeCurrentUrl = ->
	route(location, { replace: true })

export watch = (callback) ->
	watchers.push(callback)