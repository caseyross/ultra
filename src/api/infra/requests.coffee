import {
	ApiError,
	ApiConnectionError,
	ApiCredentialsError,
	ApiOtherError,
	ApiRatelimitError,
	ApiRedirectError,
	ApiRequestError,
	ApiServerError
} from '../errors/index.coffee'
import {
	checkCredentialsRemainingTime,
	renewCredentials
} from './credentials.coffee'
import {
	checkRatelimitWait,
	updateObservedRatelimit,
	updatePredictedRatelimit
} from './ratelimit.coffee'

export get = (endpoint, query) ->
	attemptRequest 'GET', endpoint, { query }

export patch = (endpoint, content) ->
	attemptRequest 'PATCH', endpoint, { content }

export post =  (endpoint, content) ->
	attemptRequest 'POST', endpoint, { content }

export put = (endpoint, content) ->
	attemptRequest 'PUT', endpoint, { content }

attemptRequest = (method, endpoint, { query, content }) ->
	new Promise (fulfill) ->
		if checkCredentialsRemainingTime() <= 0
			throw new ApiCredentialsError({ message: 'no valid credentials for request' })
		fulfill()
	.catch ->
		renewCredentials()
	.then ->
		wait = checkRatelimitWait()
		if wait > 0
			throw new ApiRatelimitError({ wait })
	.then ->
		params =
			headers:
				'Accept': 'application/json, */*;q=0.5'
				'Authorization': localStorage['api.credentials.key.token']
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
			throw new ApiConnectionError({ cause: error })
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
				throw new ApiRedirectError({ code })
			when 400 <= code <= 499
				throw new ApiRequestError({ code })
			when 500 <= code <= 599
				throw new ApiServerError({ code })
	.catch (error) ->
		switch
			when error instanceof ApiError
				throw error
			else
				throw new ApiOtherError({ cause: error })