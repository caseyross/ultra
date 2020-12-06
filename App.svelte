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

	import Main from '/Main'
	import ActionMenu from '/comp/ActionMenu'
	import DebugInspector from '/comp/DebugInspector'

	import FeedState from '/state/FeedState'
	import UserState from '/state/UserState'

	## INIT / COLD LOAD ##
	nextState =
		feed: {}
		user: {}
	state =
		feed: new FeedState()
		user: new UserState()
	state.feed.sync()

	## LINK HOT LOAD ##
	document.addEventListener 'mousedown',
		(e) -> for element in e.path
			if element.tagName is 'BUTTON'
				console.log element
				break
			if element.href
				nextState.feed = new FeedState(new URL(element.href))
				nextState.feed.sync(state.feed)
				break
	document.addEventListener 'click',
		(e) -> for element in e.path
			if element.href
				e.preventDefault()
				state = nextState
				history.pushState({ id: state.id, ranking: state.ranking }, '', element.href)
				break
	window.addEventListener 'popstate',
		(e) ->
			console.log state
			nextState.feed = new FeedState()
			nextState.feed.sync(state.feed)
			state = nextState

	inspect = off
	document.keyboardShortcuts.Backquote =
		n: 'Toggle Inspector'
		d: () => inspect = !inspect

</script>