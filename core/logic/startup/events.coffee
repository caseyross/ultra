import stateFromURL from '../state/stateFromURL.coffee'
import { sendVote } from '../../../scripts/api/API.coffee'

TODO = (state, event) ->
	Warn('Handler not implemented:', event)
	return state

export default

	keydown:
		a: (state, event) ->
			if (event.key == 'Enter') and (event.target.origin == window.location.origin)
				event.preventDefault()
				history.pushState({}, '', event.target.href)
				return {
					...state
					...stateFromURL()
				}
			return state
		*: (state, event) ->
			switch
				when state.directory.isOpen
					switch
						when event.key is 'Escape'
							return {
								...state
								directory: {
									...state.directory
									isOpen: false
								}
							}
						###
						when '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_/'.indexOf(event.key) >= 0
							newUserFilterText = state.userFilterText + event.key
							matches = 
							return {
								...state
								directory: {
									...state.directory
									matches: 
									userFilterText: newUserFilterText
								}
							}
						when event.key is 'Backspace'
							newUserFilterText = if event.ctrlKey or event.altKey then '' else state.userFilterText.slice(0, -1)
							return {
								...state
								directory: {
									...state.directory
									userFilterText: newUserFilterText
								}
							}
						when event.key is 'Enter'
							if state.directory.bestMatch
								history.pushState({}, '', '/' + state.directory.bestMatch)
								return {
									...state
									directory:
										...state.directory
										isOpen: false
										userFilterText: ''
									...stateFromURL()
								}
						###
						else
							return state
				else
					switch event.key
						when 'Escape'
							return {
								...state
								directory: {
									...state.directory
									isOpen: true
								}
							}
						when 'a'
							return {
								...state
								postIndex: state.postIndex - 1
							}
						when 'd'
							return {
								...state
								postIndex: state.postIndex + 1
							}
						else
							return state