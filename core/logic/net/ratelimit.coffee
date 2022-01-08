import { API_RATELIMIT_PERIOD_LENGTH, API_RATELIMIT_REQUESTS_PER_PERIOD } from '../../../config/api.js'

getTimeline = ->
	if MACHINE.API_REQUEST_TIMELINE
		timeline = MACHINE.API_REQUEST_TIMELINE.split(" ").map((d) -> Number(d))
	else
		timeline = []
	# Prune history for requests that no longer affect the ratelimit, and write updated timeline back.
	prunedTimeline = timeline.filter((d) -> d + API_RATELIMIT_PERIOD_LENGTH > Date.now())
	MACHINE.API_REQUEST_TIMELINE = prunedTimeline.join(" ")
	return prunedTimeline

export countRatelimit = (numRequests) ->
	timeline = getTimeline()
	timeline.unshift(Date.now()) for [1..numRequests]
	MACHINE.API_REQUEST_TIMELINE = timeline.join(" ")

export getRatelimitStatus = ->
	timeline = getTimeline()
	return
		period: API_RATELIMIT_PERIOD_LENGTH
		quota: API_RATELIMIT_REQUESTS_PER_PERIOD
		used: timeline.length

export getRatelimitWaitTime = (numRequests) ->
	timeline = getTimeline()
	if timeline.length < API_RATELIMIT_REQUESTS_PER_PERIOD
		return 0
	if numRequests > API_RATELIMIT_REQUESTS_PER_PERIOD
		return API_RATELIMIT_PERIOD_LENGTH
	return timeline.last() + API_RATELIMIT_PERIOD_LENGTH - Date.now()

export class RatelimitError extends Error
	constructor: ->
		super()
		@name = 'RatelimitError'
		@waitTime = getRatelimitWaitTime(1)
		@message = "Reddit limits how quickly we can send requests to its servers. We have to wait #{@waitTime // Date.seconds(1)}s to request more data."