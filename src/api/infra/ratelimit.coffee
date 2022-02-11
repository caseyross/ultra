DEFAULT_PERIOD = Date.minutes(1)
DEFAULT_QUOTA = 60

calcTimeline = ->
	# We keep a timeline of when API requests were issued, in order to predict the current ratelimit usage.
	timeline = if localStorage['api.ratelimit.timeline'] then localStorage['api.ratelimit.timeline'].split(" ").map((d) -> Number d) else []
	# Prune history for requests that no longer affect the ratelimit, and write updated timeline back.
	prunedTimeline = timeline.filter((d) -> d + DEFAULT_PERIOD > Date.now())
	localStorage['api.ratelimit.timeline'] = prunedTimeline.join(" ")
	return prunedTimeline

export checkRatelimitWait = ->
	# Check external values from API response headers.
	if Number(localStorage['api.ratelimit.remaining.quota']) < 1
		return Number(localStorage['api.ratelimit.remaining.period'])
	# Check internal predictions.
	timeline = calcTimeline()
	if timeline.length >= DEFAULT_QUOTA
		return timeline.last() + DEFAULT_PERIOD - Date.now()
	return 0

# In some cases, the client's ratelimit can be less than the default 60/minute. We need to track and obey such restrictions.
export updateObservedRatelimit = ({ remainingPeriod, remainingQuota }) ->
	localStorage['api.ratelimit.remaining.quota'] = remainingQuota
	localStorage['api.ratelimit.remaining.period'] = remainingPeriod

export updatePredictedRatelimit = (numRequests) ->
	timeline = calcTimeline()
	timeline.unshift(Date.now()) for [1..numRequests]
	localStorage['api.ratelimit.timeline'] = timeline.join(" ")