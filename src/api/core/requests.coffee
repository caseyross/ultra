import { ApiError } from './errors.coffee'
import { checkCredentialsRemainingTime, renewCredentials } from './credentials.coffee'
import { checkRatelimitWait, updateObservedRatelimit, updatePredictedRatelimit } from './ratelimit.coffee'

export get = (endpoint, query) ->
	attemptRequest 'GET', endpoint, { query }

export patch = (endpoint, content) ->
	attemptRequest 'PATCH', endpoint, { content }

export post =  (endpoint, content) ->
	attemptRequest 'POST', endpoint, { content }

export put = (endpoint, content) ->
	attemptRequest 'PUT', endpoint, { content }

attemptRequest = (method, endpoint, { query, content }) ->
	new Promise ->
		if checkCredentialsRemainingTime() <= 0
			throw new ApiError 'No valid API credentials.', { cause: error, type: ApiError.TYPE_CREDENTIALS }
	.catch ->
		renewCredentials()
	.then ->
		wait = checkRatelimitWait()
		if wait > 0
			throw new ApiError 'API request would exceed allowed ratelimit.', { cause: error, type: ApiError.TYPE_RATELIMIT, wait }
	.then ->
		params =
			headers:
				'Accept': 'application/json, */*;q=0.5'
				'Authorization': localStorage['api.credentials.access_token']
			cache: 'no-cache'
			method: method
		switch method
			when 'PATCH', 'POST', 'PUT'
				params.headers['Content-Type'] = 'application/json'
				params.body = JSON.stringify content
		for key, value of query
			if !value? then delete query[key]
		# NOTE: for legacy compatibility, the API replaces special characters in responses with their corresponding HTML entities.
		# Activating the raw_json parameter disables this behavior.
		query.raw_json = 1
		fetch 'https://oauth.reddit.com' + endpoint  + '?' + (new URLSearchParams query).toString(), params
	.catch (error) ->
		if error instanceof TypeError
			# NOTE: an error here means that either the network request failed OR the fetch params were structured badly.
			# The fetch API does not distinguish between these errors, so we make the assumption here that our params are OK.
			throw new ApiError 'Failed to connect to API server.', { cause: error, type: ApiError.TYPE_CONNECTION }
		else
			throw error
	.then (response) ->
		updateObservedRatelimit({
			remainingPeriod: Date.seconds(response.headers.get 'X-Ratelimit-Reset')
			remainingQuota: response.headers.get 'X-Ratelimit-Remaining'
		})
		updatePredictedRatelimit(1)
		code = response.status
		switch
			when 100 <= code <= 299
				response.json()
			when 300 <= code <= 399
				throw new ApiError 'API server reports redirect for resource.', { cause: error, type: ApiError.TYPE_RESOURCE, code }
			when 400 <= code <= 499
				throw new ApiError 'API server reports problem with our request.', { cause: error, type: ApiError.TYPE_REQUEST, code }
			when 500 <= code <= 599
				throw new ApiError 'API server reports problem on server.', { cause: error, type: ApiError.TYPE_SERVER, code }
			else
				throw new ApiError 'API request returned unknown status code.', { cause: error, type: ApiError.TYPE_OTHER }
	.catch (error) ->
		switch
			when error instanceof ApiError
				throw error
			when error instanceof SyntaxError
				throw new ApiError 'Failed to parse API response data as JSON.', { cause: error, type: ApiError.TYPE_OTHER }
			else
				throw new ApiError 'Failed to get API response for unknown reasons.', { cause: error, type: ApiError.TYPE_OTHER }