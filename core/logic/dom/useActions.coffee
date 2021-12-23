export setScroll = (element, scroll) ->
	if Number.isFinite(scroll)
		element.scrollTop = scroll