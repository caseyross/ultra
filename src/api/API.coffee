import { cacheFunctionAs } from '../cache/cache.coffee'
import { checkRatelimit } from './ratelimit.coffee'
import { renewKey } from './key.coffee'
import Model from '../model/Model.coffee'

call = ({ method, path, body }) ->
	if !isFinite(LS.keyExp) then await renewKey() # No key...
	if Number(LS.keyExp) < Date.now() then await renewKey() # Key expired...
	waitTime = checkRatelimit()
	if waitTime > 0
		Promise.reject(new RateLimitError("Request would exceed Reddit's API limits. Wait #{waitTime // 1000} seconds."))
	else
		fetch 'https://oauth.reddit.com' + path,
			method: method
			headers:
				'Authorization': LS.keyType + ' ' + LS.keyVal
			body: body
		.then (response) ->
			response.json()
		.finally ->
			if (Number(LS.keyExp) - Date.now()) < 3000000 then renewKey() # Try to maintain 50 minutes validity on key, to minimize forced renewals.

export default
	get: ({ endpoint, cache, automodel, ...options }) ->
		for name, value of options
			if not value and value isnt 0 then delete options[name] # Don't send keys with empty values.
		options.raw_json = 1
		request = -> call
			method: 'GET'
			path: endpoint + '?' + (new URLSearchParams(options)).toString()
		promise =
			if cache
				cacheFunctionAs cache, request
			else
				request()
		promise.then (data) -> if automodel then new Model(data) else data
	post: ({ endpoint, ...content }) ->
		for name, value of content
			if not value and value isnt 0 then delete content[name] # Don't send keys with empty values.
		call
			method: 'POST'
			path: endpoint
			body: new URLSearchParams(content)