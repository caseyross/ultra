RATELIMIT_PERIOD_LENGTH = Date.minutes(10)
RATELIMIT_REQUESTS_PER_PERIOD = 600

checkRequestTimeline = ->
	if browser.API_REQUEST_TIMELINE
		timeline = browser.API_REQUEST_TIMELINE.split(" ").map((d) -> Number(d))
	else
		timeline = []
	# Prune history for requests that no longer affect the ratelimit, and write updated timeline back.
	prunedTimeline = timeline.filter((d) -> d + RATELIMIT_PERIOD_LENGTH > Date.now())
	browser.API_REQUEST_TIMELINE = prunedTimeline.join(" ")
	return prunedTimeline

export checkRatelimitWait = (numRequests) ->
	timeline = checkRequestTimeline()
	if timeline.length < RATELIMIT_REQUESTS_PER_PERIOD
		return 0
	if numRequests > RATELIMIT_REQUESTS_PER_PERIOD
		return RATELIMIT_PERIOD_LENGTH
	return timeline.last() + RATELIMIT_PERIOD_LENGTH - Date.now()

export spendRatelimit = (numRequests) ->
	timeline = checkRequestTimeline()
	timeline.unshift(Date.now()) for [1..numRequests]
	browser.API_REQUEST_TIMELINE = timeline.join(" ")