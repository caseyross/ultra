import { getCredentialsTimeLeft, renewCredentials } from './internals/authentication.coffee'
import { countRatelimit, getRatelimitWaitTime } from './internals/ratelimit.coffee'

export default

	'begin api request': ({
		method, # HTTP method
		path, # Remote path
		query = {} # Query parameters for GET/HEAD
		body = {}, # Body for POST, etc.
		key = '', # Object key to store returned data under (also used to mark loading status)
		parse = null # Function used to derive objects from returned data (overriding "key" parameter if also present)
	}) ->
		#
		# check API credentials
		#
		if getCredentialsTimeLeft() <= 0
			# if invalid, get new credentials and try the request again
			command {
				type: 'end api request',
				status: 'credential-error'
			}
			renewCredentials().then ->
				command {
					type: 'begin api request'
					method
					path
					query
					body
					key
					parse
				}
			return null
		#
		# check ratelimit
		#
		wait = getRatelimitWaitTime(1)
		if wait > 0
			command(
				type: 'end api request'
				status: 'ratelimit-error'
				wait
			)
			return null
		#
		# build request
		#
		if !method or !path
			throw new Error('HTTP method and remote path must be specified for API requests.')
		if !key and !parse
			throw new Error('Object key or object parse function must be specified for API requests.')
		for key, value of query
			if !value? then delete query[key]
		query.raw_json = 1 # tell the API not to HTML-encode chars in the response
		endpoint = 'https://oauth.reddit.com' + path  + '?' + (new URLSearchParams(query)).toString()
		aborter = new AbortController()
		options = {
			method
			headers:
				'Accept': 'application/json, */*;q=0.5'
				'Authorization': browser.OAUTH_ACCESS_TOKEN
			cache: 'no-cache'
			signal: aborter.signal
		}
		switch method
			when 'PATCH', 'POST', 'PUT'
				options.headers['Content-Type'] = 'application/json'
				options.body = JSON.stringify(message)
		#
		# queue up request & aftereffects, and send
		#
		fetch(endpoint, options)
		.catch (error) ->
			command {
				type: 'end api request'
				status: 'network-error'
				error
				key
			}
			Promise.reject()
		.then (response) ->
			countRatelimit(1)
			if !response.ok
				command {
					type: 'end api request'
					status: 'request-error'
					error: response.statusText
					code: response.status
					key
				}
				Promise.reject()
			else
				response.json()
				.catch (error) ->
					command {
						type: 'end api request'
						status: 'parse-error'
						error
						body: response.body
						key
					}
					Promise.reject()
				.then (data) ->
					command {
						type: 'end api request'
						status: 'complete'
						key
						parse
						data
					}
		#
		# return
		#
		if key
			return {
				loading:
					[key]: aborter
			}
		else
			return null

	'end api request': ({ status, wait, error, code, key, parse, data }) ->
		switch status
			when 'credential-error'
				return null
			when 'ratelimit-error'
				return null
			when 'network-error'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'request-error'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'parse-error'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'complete'
				objects = if parse then parse(data) else { [key]: data }
				vintage = {}
				for objectKey of objects
					vintage[objectKey] = Date.now()
				result = {
					objects
					vintage
				}
				if key
					result.loading[key] = false
				return result
			else
				throw new Error('Unknown API request status: "' + status + '"')