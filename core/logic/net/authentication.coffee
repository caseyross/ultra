import { OAUTH_REDIRECT_URI, OAUTH_TARGET_SCOPES } from '../../../config/oauth.js'
import { API_CLIENT_ID } from '../../../config/obscured.js'

export getCredentialsTimeLeft = ->
	if not browserState.ACCESS_TOKEN
		return 0
	validityStartDate = Number(browserState.ACCESS_TOKEN_VALIDITY_PERIOD_START)
	if not Number.isFinite(validityStartDate)
		return 0
	validityPeriod = Number(browserState.ACCESS_TOKEN_VALIDITY_PERIOD)
	if not Number.isFinite(validityPeriod)
		return 0
	return validityStartDate + validityPeriod - Date.now()

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if browserState.RENEWING_CREDENTIALS is 'TRUE'
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(ensureCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	browserState.RENEWING_CREDENTIALS = 'TRUE'
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			# HTTP Basic Auth
			'Authorization': 'Basic ' + btoa(REDDIT_CLIENT_ID + ':')
		body: new URLSearchParams(
			switch
				# Request for credentials for a user who just authorized our client.
				when browserState.LOGIN_VOUCHER
					code = browserState.LOGIN_VOUCHER
					delete browserState.LOGIN_VOUCHER
					{
						grant_type: 'authorization_code'
						code: code
						redirect_uri: OAUTH_REDIRECT_URI
					}
				# Request for credentials for a user who's already "logged in" on our client.
				when browserState.REFRESH_TOKEN
					{
						grant_type: 'refresh_token'
						refresh_token: browserState.REFRESH_TOKEN
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
			browserState.ACCESS_TOKEN_VALIDITY_PERIOD_START = Date.now()
			browserState.ACCESS_TOKEN_VALIDITY_PERIOD = Date.seconds(response.expires_in)
			browserState.ACCESS_TOKEN = response.token_type + ' ' + response.access_token
			if response.refresh_token
				browserState.REFRESH_TOKEN = response.refresh_token
	.finally ->
		browserState.RENEWING_CREDENTIALS = 'FALSE'

waitForCredentialsRenewal = (f) ->
	if browserState.RENEWING_CREDENTIALS is 'TRUE'
		return setTimeout(waitForCredentialsRenewal, 20, f)
	else
		return f()

ensureCredentialsRenewal = (f) ->
	if browserState.RENEWING_CREDENTIALS is 'TRUE'
		browserState.RENEWING_CREDENTIALS = 'FALSE'
		return f(renewCredentials())
	else
		return f()

export invalidateCredentials = ->
	delete browserState.ACCESS_TOKEN
	delete browserState.ACCESS_TOKEN_VALIDITY_PERIOD
	delete browserState.ACCESS_TOKEN_VALIDITY_PERIOD_START
	delete browserState.REFRESH_TOKEN
 
export requestLogin = ->
	browserState.LOGIN_ECHO = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
	authorizationParams = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: OAUTH_TARGET_SCOPES.join(),
		client_id: REDDIT_CLIENT_ID,
		redirect_uri: OAUTH_REDIRECT_URI,
		state: browserState.LOGIN_ECHO
	)
	authorizationURL = 'https://www.reddit.com/api/v1/authorize?' + authorizationParams.toString()
	window.location.href = authorizationURL

# No specific logout function; simply use query parameter "logout" on any page load to logout.

export processLoginOrLogout = ->
	p = new URLSearchParams(window.location.search)
	switch
		# Login request
		when p.has('login')
			requestLogin()
		# Successful login
		when p.has('code') and p.get('state') is browserState.LOGIN_ECHO
			invalidateCredentials()
			delete browserState.LOGIN_ECHO
			browserState.LOGIN_VOUCHER = p.get('code')
			returnURL = window.location.origin + p.get('state').split('*')[0]
			history.replaceState({}, '', returnURL)
		# Failed login
		when p.has('error')
			alert p.get('error')
		# Logout
		when p.has('logout')
			invalidateCredentials()
			returnURL = window.location.origin + window.location.pathname
			history.replaceState({}, '', returnURL)

export hasUserCredentials = ->
	if browserState.REFRESH_TOKEN
		true
	else
		false