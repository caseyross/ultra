import stateFromURL from '../state/stateFromURL.coffee'
import { upvote } from '../../../scripts/api/API.coffee'

TODO = (state, event) ->
	Warn('Handler not implemented:', event)
	return state

export default
	popstate:
		'*': (state, event) ->
			event.preventDefault()
			return {
				...state
				...stateFromURL()
			}
	bubblingscroll:
		'#feed': TODO
		'#comments': (state, event) ->
			if state.scrolls[event.target.dataset.postId] == event.target.scrollTop 
				return state
			return {
				...state
				scrolls: {
					...state.scrolls
					[event.target.dataset.postId]: event.target.scrollTop
				}
			}
	click:
		'a': (state, event) ->
			if (event.target.origin == window.location.origin) and (event.buttons == 0) and !(event.altKey or event.ctrlKey or event.metaKey)
				event.preventDefault()
				history.pushState({}, '', event.target.href)
				return {
					...state
					...stateFromURL()
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
	mouseover:
		'article': (state, event) ->
			id = event.target.dataset.id
			console.log id
			if id and state.itemId != id
				console.log 'select'
				return {
					...state
					itemId: id
				}
			return state
	contextmenu:
		'.post': TODO
		'.comment': TODO
	keydown:
		'a': (state, event) ->
			if (event.key == 'Enter') and (event.target.origin == window.location.origin)
				event.preventDefault()
				history.pushState({}, '', event.target.href)
				return {
					...state
					...stateFromURL()
				}
			return state
		'*': (state, event) ->
			switch event.key
				when 'Escape'
					return {
						...state
						showMenu: !state.showMenu
					}
				else
					return state