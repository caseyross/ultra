import { ApiError } from './errors.coffee'
import { API_REGISTERED_POSTAUTH_URL } from '../config.js'
import { API_CLIENT_ID } from '../config-obscured.js'

export checkCredentialsRemainingTime = ->
	if !localStorage['api.credentials.key.token']? then return 0
	expiration = Number localStorage['api.credentials.key.expiration']
	if !Number.isFinite expiration then return 0
	return expiration - Date.now()

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if localStorage['api.credentials.renewal_in_progress'] is 'TRUE'
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(forceCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	localStorage['api.credentials.renewal_in_progress'] = 'TRUE'
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	auth_code = localStorage['api.credentials.exchange.auth_code']
	delete localStorage['api.credentials.exchange.auth_code'] # no reuse of auth codes allowed
	refresh_token = localStorage['api.credentials.exchange.token']
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(API_CLIENT_ID + ':') # HTTP Basic Auth
		body: JSON.stringify(
			switch
				when auth_code # New account login
					{
						grant_type: 'authorization_code'
						code: auth_code
						redirect_uri: API_REGISTERED_POSTAUTH_URL
					}
				when refresh_token # Existing login, but credentials expired
					{
						grant_type: 'refresh_token'
						refresh_token: refresh_token
					}
				else # Logged-out credentials
					{
						grant_type: 'https://oauth.reddit.com/grants/installed_client'
						device_id: 'DO_NOT_TRACK_THIS_DEVICE' # required field, but we have the option of using this value
					}
		)
	.catch (error) ->
		if error instanceof TypeError
			# NOTE: an error here means that either the network request failed OR the fetch params were structured badly.
			# The fetch API does not distinguish between these errors, so we make the assumption here that our params are OK.
			throw new ApiError 'Failed to connect to API server.', { cause: error, type: ApiError.TYPE_CONNECTION }
		else
			throw error
	.then (response) ->
		response.json()
	.then (data) ->
		if data.token_type? and data.access_token? and isFinite(data.expires_in)
			localStorage['api.credentials.key.token'] = data.token_type + ' ' + data.access_token
			localStorage['api.credentials.key.expiration'] = Date.now() + Date.seconds(data.expires_in)
			if data.refresh_token?
				localStorage['api.credentials.exchange.token'] = data.refresh_token
	.finally ->
		localStorage['api.credentials.renewal_in_progress'] = 'FALSE'
		if checkCredentialsRemainingTime() <= 0
			throw new ApiError 'Failed to acquire valid API credentials.', { type: ApiError.TYPE_CREDENTIALS }

waitForCredentialsRenewal = (f) ->
	if localStorage['api.credentials.renewal_in_progress'] is 'TRUE'
		return setTimeout(waitForCredentialsRenewal, 20, f)
	else
		return f()

forceCredentialsRenewal = (f) ->
	if localStorage['api.credentials.renewal_in_progress'] is 'TRUE'
		localStorage['api.credentials.renewal_in_progress'] = 'FALSE'
		return f(renewCredentials())
	else
		return f()

export deleteLocalCredentials = ->
	delete localStorage['api.credentials.exchange.token']
	delete localStorage['api.credentials.key.expiration']
	delete localStorage['api.credentials.key.token']