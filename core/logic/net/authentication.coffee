import { OAUTH_AFTERLOGIN_REDIRECT_URL, OAUTH_SCOPES_REQUIRED } from '../../../config/api.js'
import { API_ASSIGNED_APPLICATION_ID } from '../../../config/obscured.js'

export getCredentialsTimeLeft = ->
	if not MACHINE.OAUTH_ACCESS_TOKEN
		return 0
	validityStart = Number(MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_PERIOD_START)
	if not Number.isFinite(validityStartDate)
		return 0
	validityLength = Number(MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_PERIOD_LENGTH)
	if not Number.isFinite(validityPeriod)
		return 0
	return validityStart + validityLength - Date.now()

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if MACHINE.OAUTH_RENEWING is 'TRUE'
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(ensureCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	MACHINE.OAUTH_RENEWING = 'TRUE'
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			# HTTP Basic Auth
			'Authorization': 'Basic ' + btoa(API_ASSIGNED_APPLICATION_ID + ':')
		body: new URLSearchParams(
			switch
				# Request for credentials for a user who just authorized our client.
				when MACHINE.OAUTH_AUTH_CODE
					code = MACHINE.OAUTH_AUTH_CODE
					delete MACHINE.OAUTH_AUTH_CODE
					{
						grant_type: 'authorization_code'
						code: code
						redirect_uri: OAUTH_AFTERLOGIN_REDIRECT_URL
					}
				# Request for credentials for a user who's already "logged in" on our client.
				when MACHINE.OAUTH_REFRESH_TOKEN
					{
						grant_type: 'refresh_token'
						refresh_token: MACHINE.OAUTH_REFRESH_TOKEN
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
			MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_START = Date.now()
			MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_LENGTH = Date.seconds(response.expires_in)
			MACHINE.OAUTH_ACCESS_TOKEN = response.token_type + ' ' + response.access_token
			if response.refresh_token
				MACHINE.OAUTH_REFRESH_TOKEN = response.refresh_token
	.finally ->
		MACHINE.OAUTH_RENEWING = 'FALSE'

waitForCredentialsRenewal = (f) ->
	if MACHINE.OAUTH_RENEWING is 'TRUE'
		return setTimeout(waitForCredentialsRenewal, 20, f)
	else
		return f()

ensureCredentialsRenewal = (f) ->
	if MACHINE.OAUTH_RENEWING is 'TRUE'
		MACHINE.OAUTH_RENEWING = 'FALSE'
		return f(renewCredentials())
	else
		return f()

export invalidateCredentials = ->
	delete MACHINE.OAUTH_ACCESS_TOKEN
	delete MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_START
	delete MACHINE.OAUTH_ACCESS_TOKEN_VALIDITY_LENGTH
	delete MACHINE.OAUTH_REFRESH_TOKEN
 
export requestLogin = ->
	MACHINE.OAUTH_ECHO_VALUE = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
	authorizationParams = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: OAUTH_SCOPES_REQUIRED.join(),
		client_id: API_ASSIGNED_APPLICATION_ID,
		redirect_uri: OAUTH_AFTERLOGIN_REDIRECT_URL,
		state: MACHINE.OAUTH_ECHO_VALUE
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
		when p.has('code') and p.get('state') is MACHINE.OAUTH_ECHO_VALUE
			invalidateCredentials()
			delete MACHINE.OAUTH_ECHO_VALUE
			MACHINE.OAUTH_AUTH_CODE = p.get('code')
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
	if MACHINE.OAUTH_REFRESH_TOKEN
		true
	else
		false