export default (state, timers) ->
	for interval, handler of timers
		setInterval(
			-> state = handler(state)
			interval
		)