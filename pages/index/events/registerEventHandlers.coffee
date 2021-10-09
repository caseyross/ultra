export default (state, events) ->
	for eventName, handlers of events
		window.addEventListener(
			eventName,
			(event) ->
				for pattern, handler of handlers
					if event.target.matches(pattern)
						state = handler(state, event)
		)