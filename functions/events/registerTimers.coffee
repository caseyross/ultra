export (state, timers) ->
	for interval, handler of timers
		setInterval(
			-> state = handler(state)
			interval
		)