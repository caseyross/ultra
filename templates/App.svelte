<template lang='pug'>

	svelte:head
		title {state.listingId[0] === 'r' ? state.listingId.slice(2) : state.listingId}
	AppNav(state='{state}')
	AppMain(state='{state}')
	ActionMenu
	+if('inspect')
		#inspector-overlay
			DebugInspector(key='state' value='{state}')

</template><style>

	#inspector-overlay
		position fixed
		top 0
		width 100vw
		height 100vh
		padding 1% 0
		overflow auto
		background #fed
		color black

</style><script>

	import State from '/objects/State'
	import ActionMenu from '/templates/ActionMenu'
	import AppMain from '/templates/AppMain'
	import AppNav from '/templates/AppNav'
	import DebugInspector from '/templates/DebugInspector'

	# Initialize.
	state = new State(window.location)
	preloads = {}
	# Preload internal links...
	document.addEventListener 'mousedown',
		(e) ->
			for element in e.path
				if element.href
					url = new URL(element.href)
					if url.origin is window.location.origin
						preloads[url.pathname] = new State(url, state)
					break
	# ...then hot load them into the page.
	document.addEventListener 'click',
		(e) ->
			for element in e.path
				if element.href
					url = new URL(element.href)
					if url.origin is window.location.origin
						[ nothing, listingType, listingName, selections ] = url.pathname.split('/')
						if not selections
							history.pushState({}, '', element.href)
						state = preloads[url.pathname] ? new State(url, state)
						delete preloads[url.pathname]
						e.preventDefault()
					break
	# Also hot load when the browser back function is used.
	window.addEventListener 'popstate',
		(e) ->
			state = new State(window.location, state)

	inspect = off
	document.keyboardShortcuts.Backquote =
		n: 'Toggle Inspector'
		d: () => inspect = !inspect

</script>