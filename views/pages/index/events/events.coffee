export default
	popstate:
		'*': (state, event) ->
			return {
				...state
				stateFromURL()
			}
	scroll:
		'#feed': TODO
		'.comments': TODO
	click:
		'a': (state, event) ->
			if (event.target.origin is window.location.origin) and (e.buttons is 0) and not (e.altKey or e.ctrlKey or e.metaKey)
				event.preventDefault()
				history.pushState({}, '', event.target.href)
				return {
					...state
					stateFromURL()
				}
			return state
		'.post': (state, event) ->
			fullname = event.target.dataset.fullname
			upvote(fullname)
			return {
				...state
				votes: state.votes.set(fullname, 1)
			}
		'.comment': (state, event) ->
			fullname = event.target.dataset.fullname
			upvote(fullname)
			return {
				...state
				votes: state.votes.set(fullname, 1)
			}
	contextmenu:
		'.post': TODO
		'.comment': TODO
	keydown:
		'a': (state, event) ->
			if (event.key is 'Enter') and (event.target.origin is window.location.origin)
				event.preventDefault()
				history.pushState({}, '', event.target.href)
				return {
					...state
					stateFromURL()
				}
			return state
		'*': (state, event) ->
			switch event.key
				when 'Escape':
					return {
						...state
						showMenu: !state.showMenu
					}
				else
					return state

TODO = (state, event) ->
	console.log event
	return state