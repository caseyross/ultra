class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'

export checkRatelimit = ->
	current = if LS.calls then LS.calls.split(',') else []
	revised = current.filter((x) -> Number(x) > Date.now())
	if revised.length > 600 then return Number(revised[0]) - Date.now() # Prohibit having > 600 requests on quota at any time.
	revised.push(Date.now() + 600000) # Requests occupy ratelimit quota space for 10 minutes after being sent.
	LS.calls = revised.join()
	return 0