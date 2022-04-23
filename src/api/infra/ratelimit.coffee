ratelimit = {

	# Upon startup, or in the case that the server fails to provide ratelimit feedback, we need to assume ratelimit parameters.
	sanitize: ->
		remaining = Number localStorage['api.ratelimit.remaining']
		reset = Number localStorage['api.ratelimit.reset']
		if not Number.isFinite(reset) or reset < Date.now()
			localStorage['api.ratelimit.reset'] = Date.now() + Date.seconds(60)
			localStorage['api.ratelimit.remaining'] = 60
		else if not Number.isFinite(remaining)
			localStorage['api.ratelimit.remaining'] = 60

	# Update the known ratelimit parameters with authoritative server feedback, or, failing that, with a simple count of requests sent.
	update: ({ count, remaining, timeUntilReset }) ->
		if remaining?
			localStorage['api.ratelimit.remaining'] = remaining
		else
			localStorage['api.ratelimit.remaining'] = localStorage['api.ratelimit.remaining'] - count
		if timeUntilReset?
			localStorage['api.ratelimit.reset'] = Date.now() + timeUntilReset

}

# The maximum average requests per second we can currently make before hitting the ratelimit.
Object.defineProperty(ratelimit, 'availableRPS', {
	get: ->
		ratelimit.sanitize()
		requests = Number localStorage['api.ratelimit.remaining']
		seconds = Date.asSeconds(Number(localStorage['api.ratelimit.reset']) - Date.now())
		if requests > 0 and seconds > 0
			return requests / seconds
		return 0
})

# The number of milliseconds until the current ratelimit period resets.
Object.defineProperty(ratelimit, 'timeUntilReset', {
	get: ->
		ratelimit.sanitize()
		reset = Number localStorage['api.ratelimit.reset']
		return reset - Date.now()
})

export default ratelimit