import stateFromURL from '../state/stateFromURL.coffee'
import { sendVote } from '../../../scripts/api/API.coffee'

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
		'.votable': (state, event) ->
			id = event.target.dataset.id
			priorVote = state.votes[id]
			vote = if priorVote == 1 then 0 else 1
			sendVote(id, vote)
			return {
				...state
				votes: {
					...state.votes
					[id]: vote
				}
			}
	bubblingmouseenter:
		'.post': (state, event) ->
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
		'.votable': (state, event) ->
			event.preventDefault()
			id = event.target.dataset.id
			priorVote = state.votes[id]
			vote = if priorVote == -1 then 0 else -1
			sendVote(id, vote)
			return {
				...state
				votes: {
					...state.votes
					[id]: vote
				}
			}
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