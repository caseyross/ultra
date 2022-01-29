import { getCredentialsTimeLeft, renewCredentials } from './internals/authentication.coffee'
import { countRatelimit, getRatelimitWaitTime } from './internals/ratelimit.coffee'

export default

	START_API_REQUEST: ({
		method, # HTTP method
		path, # Remote path
		query = {} # Query parameters for GET/HEAD
		body = {}, # Body for POST, etc.
		key = '', # Object key to store returned data under (also used to mark loading status)
		parse = null # Function used to derive objects from returned data (overriding "key" parameter if also present)
	}) ->
		#
		# check parameters
		#
		if !method or !path
			throw new Error('HTTP method and remote path must be specified for API requests.')
		if !key and !parse
			throw new Error('Object key or parse function must be specified for API requests.')
		#
		# check API credentials
		#
		if getCredentialsTimeLeft() <= 0
			# if invalid, get new credentials and try the request again
			END_API_REQUEST({ status: 'CREDENTIAL_ERROR' })
			renewCredentials().then ->
				START_API_REQUEST({
					method
					path
					query
					body
					key
					parse
				})
			return null
		#
		# check ratelimit
		#
		wait = getRatelimitWaitTime(1)
		if wait > 0
			END_API_REQUEST({ status: 'RATELIMIT_ERROR', wait })
			return null
		#
		# build request
		#
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
		# queue up request
		#
		fetch(endpoint, options).catch((error) ->
			END_API_REQUEST({ status: 'NETWORK_ERROR', error, key })
			Promise.reject()
		).then((response) ->
			countRatelimit(1)
			if !response.ok
				END_API_REQUEST({ status: 'REQUEST_ERROR', error: response.statusText, code: response.status, key })
				Promise.reject()
			else
				response.json().catch((error) ->
					END_API_REQUEST({ status: 'PARSE_ERROR', error, body: response.body, key })
					Promise.reject()
				).then (data) ->
					END_API_REQUEST({ status: 'SUCCESS', key, parse, data })
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

	END_API_REQUEST: ({ status, wait, error, code, key, parse, data }) ->
		#
		# TODO:
		# if apiRequestError then set error[key] = apiRequestError
		#
		switch status
			when 'CREDENTIAL_ERROR'
				return null
			when 'RATELIMIT_ERROR'
				return null
			when 'NETWORK_ERROR'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'REQUEST_ERROR'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'PARSE_ERROR'
				if key
					return {
						loading:
							[key]: false
					}
				else
					return null
			when 'SUCCESS'
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