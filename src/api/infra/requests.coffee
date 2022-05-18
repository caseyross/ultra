import credentials from './credentials.coffee'
import errors from './errors.coffee'
import ratelimit from './ratelimit.coffee'
import Time from '../../lib/Time.coffee'

export get = (endpoint, query) -> call('GET', endpoint, { query })
export patch = (endpoint, content) -> call('PATCH', endpoint, { content })
export post = (endpoint, content) -> call('POST', endpoint, { content })
export put = (endpoint, content) -> call('PUT', endpoint, { content })

call = (method, endpoint, { query = {}, content }) ->
	new Promise (fulfill) ->
		if not credentials.valid then throw new errors.CredentialsRequiredError({ message: 'no valid credentials for request' })
		fulfill()
	.catch ->
		credentials.renew()
	.then ->
		if not ratelimit.availableRPS > 0 then throw new errors.RatelimitExceededError({ waitMs: ratelimit.msUntilReset })
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
			config.body = JSON.stringify content
			config.headers['Content-Type'] = 'application/json'
		fetch("https://oauth.reddit.com#{endpoint}?#{queryString}", config)
	.catch (error) ->
		# NOTE: a TypeError here means that either the network request failed OR the fetch config was structured badly. `fetch` does not distinguish between these errors, so we make the assumption that the config was OK.
		if error instanceof TypeError then throw new errors.ConnectionFailedError({ cause: error })
		throw error
	.then (response) ->
		ratelimit.update({
			count: 1
			remaining: response.headers.get 'X-Ratelimit-Remaining'
			secondsUntilReset: response.headers.get 'X-Ratelimit-Reset'
		})
		code = response.status
		switch
			when 100 <= code <= 299 then response.json()
			when 300 <= code <= 399 then throw new errors.ResourceMovedError({ code })
			when 400 <= code <= 499 then throw new errors.InvalidRequestError({ code })
			when 500 <= code <= 599 then throw new errors.ServerNotAvailableError({ code })
	.catch (error) ->
		if error instanceof errors.AnyError then throw error
		throw new errors.UnknownError({ cause: error })