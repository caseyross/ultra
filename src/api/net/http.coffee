import errors from '../base/errors.coffee'
import credentials from './credentials.coffee'
import ratelimit from './ratelimit.coffee'

export get = (endpoint, query) -> call('GET', endpoint, { query })
export patch = (endpoint, content) -> call('PATCH', endpoint, { content })
export post = (endpoint, content) -> call('POST', endpoint, { content })
export put = (endpoint, content) -> call('PUT', endpoint, { content })

call = (method, endpoint, { query = {}, content = {} }) ->
	new Promise (fulfill) ->
		if not credentials.valid then throw new errors.NeedCredentials({ description: 'no valid credentials for request' })
		fulfill()
	.catch ->
		credentials.renew()
	.then ->
		if not ratelimit.availableRPS > 0 then throw new errors.OverRatelimit({ waitMs: ratelimit.msUntilReset })
	.then ->
		for key, value of query then if not value? then delete query[key]
		# NOTE: for legacy compatibility, the API replaces special characters in responses with their corresponding HTML entities. Activating the raw_json parameter disables this behavior.
		query.raw_json = 1
		queryString = (new URLSearchParams(query)).toString()
		config =
			cache: 'no-cache' # browser is only allowed to return cached data if the server also says it's "fresh"
			headers:
				Accept: 'application/json'
				Authorization: localStorage['api.credentials.key']
			method: method
		if method is 'PATCH' or method is 'POST' or method is 'PUT'
			config.body = new FormData()
			for key, value of content then config.body.set(key, value)
		fetch("https://oauth.reddit.com#{endpoint}?#{queryString}", config)
	.catch (error) ->
		# NOTE: a TypeError here means that either the network request failed OR the fetch config was structured badly. `fetch` does not distinguish between these errors, so we make the assumption that the config was OK.
		if error instanceof TypeError then throw new errors.NetworkFailure({ cause: error })
		throw error
	.then (response) ->
		ratelimit.update({
			count: 1
			remaining: Number response.headers.get('X-Ratelimit-Remaining')
			secondsUntilReset: Number response.headers.get('X-Ratelimit-Reset')
		})
		code = response.status
		response.json().then (data) ->
			# Parse "reddit standard" error objects if present.
			message = data?.json?.errors?[0]?[1] or data.message
			reason = data?.json?.errors?[0]?[0] or data.reason
			# NOTE: Almost all API error responses use non-success HTTP codes. However, for at least one endpoint, it's possible to get a 200 code with an error response.
			switch
				when 100 <= code <= 299
					if message or reason
						throw new errors.Unknown({ description: message, reason })
					else
						return data
				when 300 <= code <= 399
					# NOTE: GET responses in this range are generally handled pre-emptively by browsers.
					throw new errors.DataLocationChanged({ code, description: message, reason })
				when 400 <= code <= 499
					throw new errors.DataNotAvailable({ code, description: message, reason })
				when 500 <= code <= 599
					throw new errors.ServerFailure({ code, description: message, reason })
				else
					throw new errors.Unknown({ description: message, reason })
	.catch (error) ->
		if error instanceof errors.Base then throw error
		throw new errors.Unknown({ cause: error })