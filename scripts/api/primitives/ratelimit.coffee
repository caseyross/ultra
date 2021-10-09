import { RATELIMIT_PERIOD, RATELIMIT_QUOTA } from '../../../config/api-config.js'

getTimeline = ->
	if Storage.API_REQUEST_TIMELINE
		timeline = Storage.API_REQUEST_TIMELINE.split(" ").map((d) -> Number(d))
	else
		timeline = []
	# Prune history for requests that no longer affect the ratelimit, and write updated timeline back.
	prunedTimeline = timeline.filter((d) -> d + RATELIMIT_PERIOD > Date.now())
	Storage.API_REQUEST_TIMELINE = prunedTimeline.join(" ")
	return prunedTimeline

export countRatelimit = (numRequests) ->
	timeline = getTimeline()
	timeline.unshift(Date.now()) for [1..numRequests]
	Storage.API_REQUEST_TIMELINE = timeline.join(" ")

export getRatelimitStatus = ->
	timeline = getTimeline()
	return
		period: RATELIMIT_PERIOD
		quota: RATELIMIT_QUOTA
		used: timeline.length

export getRatelimitWaitTime = (numRequests) ->
	timeline = getTimeline()
	if timeline.length < RATELIMIT_QUOTA
		return 0
	if numRequests > RATELIMIT_QUOTA
		return RATELIMIT_PERIOD
	return timeline.last() + RATELIMIT_PERIOD - Date.now()

export class RatelimitError extends Error
	constructor: ->
		super()
		@name = 'RatelimitError'
		@waitTime = getRatelimitWaitTime(1)
		@message = "Reddit limits how quickly we can send requests to its servers. We have to wait #{@waitTime // Date.seconds(1)}s to request more data."