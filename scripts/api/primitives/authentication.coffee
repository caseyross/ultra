import { REDDIT_CLIENT_ID } from '../../../config/api-config-obscured.js'
import { OAUTH_REDIRECT_URI, OAUTH_TARGET_SCOPES } from '../../../config/api-config.js'

export getCredentialsTimeLeft = ->
	if not Storage.ACCESS_TOKEN
		return 0
	validityStartDate = Number(Storage.ACCESS_TOKEN_VALIDITY_PERIOD_START)
	if not Number.isFinite(validityStartDate)
		return 0
	validityPeriod = Number(Storage.ACCESS_TOKEN_VALIDITY_PERIOD)
	if not Number.isFinite(validityPeriod)
		return 0
	return validityStartDate + validityPeriod - Date.now()

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if Storage.RENEWING_CREDENTIALS
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(ensureCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	Storage.RENEWING_CREDENTIALS = true
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			# HTTP Basic Auth
			'Authorization': 'Basic ' + btoa(REDDIT_CLIENT_ID + ':')
		body: new URLSearchParams(
			switch
				# Request for credentials for a user who just authorized our client.
				when Storage.LOGIN_VOUCHER
					code = Storage.LOGIN_VOUCHER
					delete Storage.LOGIN_VOUCHER
					{
						grant_type: 'authorization_code'
						code: code
						redirect_uri: OAUTH_REDIRECT_URI
					}
				# Request for credentials for a user who's already "logged in" on our client.
				when Storage.REFRESH_TOKEN
					{
						grant_type: 'refresh_token'
						refresh_token: Storage.REFRESH_TOKEN
					}
				# Request for non-user credentials.
				else
					{
						grant_type: 'https://oauth.reddit.com/grants/installed_client'
						device_id: 'DO_NOT_TRACK_THIS_DEVICE'
					}
		)
	.then (response) ->
		response.json()
	.then (response) ->
		if isFinite(response.expires_in) and response.token_type and response.access_token
			Storage.ACCESS_TOKEN_VALIDITY_PERIOD_START = Date.now()
			Storage.ACCESS_TOKEN_VALIDITY_PERIOD = Date.seconds(response.expires_in)
			Storage.ACCESS_TOKEN = response.token_type + ' ' + response.access_token
			if response.refresh_token
				Storage.REFRESH_TOKEN = response.refresh_token
	.finally ->
		Storage.RENEWING_CREDENTIALS = false

waitForCredentialsRenewal = (f) ->
	if Storage.CREDENTIAL_RENEWAL_IN_PROGRESS
		return setTimeout(waitForCredentialsRenewal, 20, f)
	else
		return f()

ensureCredentialsRenewal = (f) ->
	if Storage.RENEWING_CREDENTIALS
		Storage.RENEWING_CREDENTIALS = false
		return f(renewCredentials())
	else
		return f()

export invalidateCredentials = ->
	delete Storage.ACCESS_TOKEN
	delete Storage.ACCESS_TOKEN_VALIDITY_PERIOD
	delete Storage.ACCESS_TOKEN_VALIDITY_PERIOD_START
	delete Storage.REFRESH_TOKEN
 
export requestLogin = ->
	Storage.LOGIN_ECHO = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
	authorizationParams = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: OAUTH_TARGET_SCOPES.join(),
		client_id: REDDIT_CLIENT_ID,
		redirect_uri: OAUTH_REDIRECT_URI,
		state: Storage.LOGIN_ECHO
	)
	window.location.href = 'https://www.reddit.com/api/v1/authorize?' + authorizationParams.toString

# No specific logout function; simply use query parameter "logout" on any page load to logout.

export processLoginOrLogout = ->
	p = new URLSearchParams(window.location.search)
	switch
		# Successful login
		when p.has('code') and p.get('state') is Storage.LOGIN_ECHO
			invalidateCredentials()
			delete Storage.LOGIN_ECHO
			Storage.LOGIN_VOUCHER = p.get('code')
			cleanUrl = {
				...window.location
				pathname: p.get('state').split('*')[0]
				search: ''
			}
			history.replaceState({}, '', cleanUrl.href)
		# Failed login
		when p.has('error')
			console.log p.get('error')
		# Logout
		when p.has('logout')
			invalidateCredentials()

export getCredentialsAuthority = ->
	switch
		when Storage.REFRESH_TOKEN
			'user'
		else
			'no-user'