import Time from '../../lib/Time.coffee'

ratelimit = {

	# Upon startup, or in the case that the server fails to provide ratelimit feedback, we need to assume ratelimit parameters.
	sanitize: ->
		remaining = Number localStorage['api.ratelimit.remaining']
		reset = Number localStorage['api.ratelimit.reset']
		if not Number.isFinite(reset) or reset < Time.epochMs()
			localStorage['api.ratelimit.reset'] = Time.epochMs() + Time.sToMs(60)
			localStorage['api.ratelimit.remaining'] = 60
		else if not Number.isFinite(remaining)
			localStorage['api.ratelimit.remaining'] = 60

	# Update the known ratelimit parameters with authoritative server feedback, or, failing that, with a simple count of requests sent.
	update: ({ count, remaining, secondsUntilReset }) ->
		if remaining?
			localStorage['api.ratelimit.remaining'] = remaining
		else
			localStorage['api.ratelimit.remaining'] = localStorage['api.ratelimit.remaining'] - count
		if secondsUntilReset?
			localStorage['api.ratelimit.reset'] = Time.epochMs() + Time.sToMs(secondsUntilReset)

}

# The maximum average requests per second we can currently make before hitting the ratelimit.
Object.defineProperty(ratelimit, 'availableRPS', {
	get: ->
		ratelimit.sanitize()
		requests = Number localStorage['api.ratelimit.remaining']
		seconds = Time.msToS(Number(localStorage['api.ratelimit.reset']) - Time.epochMs())
		if requests > 0 and seconds > 0
			return requests / seconds
		return 0
})

# The number of milliseconds until the current ratelimit period resets.
Object.defineProperty(ratelimit, 'msUntilReset', {
	get: ->
		ratelimit.sanitize()
		reset = Number localStorage['api.ratelimit.reset']
		return reset - Time.epochMs()
})

export default ratelimit