import { cacheFunctionAs } from '../cache.coffee'
import { credentialsValidAt, renewCredentials } from './authentication.coffee'
import Listing from '../../models/Listing.coffee'

class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'

updateRatelimitHistory = ->
	if Storage.RATELIMIT_HIS
markRateLimit = ->

rateLimitWaitTime = (requestCount) ->
	if not Storage.RATELIMIT_HISTORY
export checkRatelimit = ->
	current = if Storage.RATELIMIT_HISTORY then Storage.RATELIMIT_HISTORY.split(',') else []
	revised = current.filter((x) -> Number(x) > Date.now())
	if revised.length > 600 then return Number(revised[0]) - Date.now() # Prohibit having > 600 requests on quota at any time.
	revised.push(Date.now() + Date.minutes(10)) # Requests occupy ratelimit quota space for 10 minutes after being sent.
	Storage.RATELIMIT_HISTORY = revised.join()
	return 0

request = ({ method, path, body }) ->
	if not credentialsValidAt(Date.now())
		await renewCredentials()
	waitTime = checkRatelimit()
	if waitTime > 0
		Promise.reject(new RateLimitError("Request would exceed Reddit's API limits. Wait #{waitTime // 1000} seconds."))
	else
		fetch 'https://oauth.reddit.com' + path, {
			method
			headers:
				'Authorization': Storage.ACCESS_TOKEN
			body
		}
		.then (response) ->
			response.json()
		.finally ->
			# If our credentials are going to expire within a certain time, pre-emptively renew them in the background to avoid forced downtime later.
			if not credentialsValidAt(Date.now() + Date.minutes(30))
				renewCredentials()

export get = ({ endpoint, cache, automodel, ...options }) ->
	for name, value of options
		if not value and value isnt 0 then delete options[name] # Don't send keys with empty values.
	options.raw_json = 1 # Opt out of legacy Reddit response encoding
	r = ->
		request
			method: 'GET'
			path: endpoint + '?' + (new URLSearchParams(options)).toString()
	promise =
		if cache
			cacheFunctionAs cache, r
		else
			r()
	promise.then (data) -> if automodel then new Listing(data) else data

export post = ({ endpoint, ...content }) ->
	for name, value of content
		if not value and value isnt 0 then delete content[name] # Don't send keys with empty values.
	call
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)