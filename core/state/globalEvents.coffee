# Add "URL change" as an event that can be reacted to.
(new MutationObserver(() ->
	{
		type: 'system'
		name: 'Load URL Internally'
		data: window.location
	}
)).observe(
	window.document,
	{
		attributes: true
		attributeFilter: 'URL'
	}
)

window.onclick = (e) ->
	# If user executes a normal click on a link to another Reddit page, "pushState" the URL instead of loading it as a new browser page.
	if e.target.href and (e.target.origin == window.document.location.origin) and (e.buttons == 1) and !(e.altKey or e.ctrlKey)
		e.preventDefault()
		window.history.pushState({}, '', e.target.href)

window.onkeydown = (e) ->
	switch
		when e.altKey
			return
		when e.ctrlKey
			return
		when e.metaKey
			return
		when e.shiftKey
			return
		else
			switch e.key
				when ''

window.setInterval(->
	{
		type: 'system'
		name: 'Update Metrics'
	},
	6000
)