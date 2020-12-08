<template lang='pug'>

	svelte:head
		title {state.feed.name || 'front page'}
	Main(state='{state}')
	ActionMenu
	+if('inspect')
		#inspector-overlay
			DebugInspector(key='state' value='{state}')

</template><style>

	#inspector-overlay
		position fixed
		top 0
		width 100%
		height 100%
		padding 1% 0
		overflow auto
		background #fed
		color black

</style><script>

	import FeedState from '/objects/FeedState'
	import ActionMenu from '/templates/ActionMenu'
	import DebugInspector from '/templates/DebugInspector'
	import Main from '/templates/Main'

	## INIT ##
	state =
		feed: new FeedState(window.location)
		feedPredict: {}
	## PRE-LOAD INTERNAL LINKS... ##
	document.addEventListener 'mousedown',
		(e) ->
			for element in e.path
				if element.href
					url = new URL(element.href)
					if url.origin is window.location.origin
						state.feedPredict[url.pathname] = new FeedState(url, state.feed)
					break
	## ...THEN HOT LOAD THEM ##
	document.addEventListener 'click',
		(e) ->
			for element in e.path
				if element.href
					url = new URL(element.href)
					if url.origin is window.location.origin
						[ empty, type, name, selections ] = url.pathname.split('/')
						if not selections
							history.pushState({}, '', element.href)
						state.feed = state.feedPredict[url.pathname] ? new FeedState(url, state.feed)
						delete state.feedPredict[url.pathname]
						e.preventDefault()
					break
	## ALSO HOT LOAD UPON BROWSER BACK FUNCTION ##
	window.addEventListener 'popstate',
		(e) ->
			state.feed = new FeedState(window.location, state.feed)

	inspect = off
	document.keyboardShortcuts.Backquote =
		n: 'Toggle Inspector'
		d: () => inspect = !inspect

</script>