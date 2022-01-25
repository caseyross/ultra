import { API_ASSIGNED_APPLICATION_ID } from '../../../config/obscured.js'
import { API_AFTERLOGIN_REDIRECT_URL, API_OAUTH_USER_SCOPES_REQUESTED } from '../../../config/api.js'

export getCredentialsTimeLeft = ->
	if !browser.OAUTH_ACCESS_TOKEN?
		return 0
	validityStart = Number(browser.OAUTH_ACCESS_TOKEN_VALIDITY_START)
	if !Number.isFinite(validityStart)
		return 0
	validityLength = Number(browser.OAUTH_ACCESS_TOKEN_VALIDITY_LENGTH)
	if !Number.isFinite(validityLength)
		return 0
	return validityStart + validityLength - Date.now()

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if browser.OAUTH_RENEWING is 'TRUE'
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(ensureCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	browser.OAUTH_RENEWING = 'TRUE'
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(API_ASSIGNED_APPLICATION_ID + ':') # HTTP Basic Auth
		body: JSON.stringify(
			switch
				# Request for credentials for a user who just authorized our client.
				when browser.OAUTH_AUTH_CODE
					code = browser.OAUTH_AUTH_CODE
					delete browser.OAUTH_AUTH_CODE
					{
						grant_type: 'authorization_code'
						code: code
						redirect_uri: API_AFTERLOGIN_REDIRECT_URL
					}
				# Request for credentials for a user who's already "logged in" on our client.
				when browser.OAUTH_REFRESH_TOKEN
					{
						grant_type: 'refresh_token'
						refresh_token: browser.OAUTH_REFRESH_TOKEN
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
	.then (data) ->
		if isFinite(data.expires_in) and data.token_type and data.access_token
			browser.OAUTH_ACCESS_TOKEN_VALIDITY_START = Date.now()
			browser.OAUTH_ACCESS_TOKEN_VALIDITY_LENGTH = Date.seconds(data.expires_in)
			browser.OAUTH_ACCESS_TOKEN = data.token_type + ' ' + data.access_token
			if data.refresh_token
				browser.OAUTH_REFRESH_TOKEN = data.refresh_token
	.finally ->
		browser.OAUTH_RENEWING = 'FALSE'
		if getCredentialsTimeLeft() <= 0
			throw new Error('Failed to acquire valid API credentials.')

waitForCredentialsRenewal = (f) ->
	if browser.OAUTH_RENEWING is 'TRUE'
		return setTimeout(waitForCredentialsRenewal, 20, f)
	else
		return f()

ensureCredentialsRenewal = (f) ->
	if browser.OAUTH_RENEWING is 'TRUE'
		browser.OAUTH_RENEWING = 'FALSE'
		return f(renewCredentials())
	else
		return f()

invalidateCredentials = ->
	delete browser.OAUTH_ACCESS_TOKEN
	delete browser.OAUTH_ACCESS_TOKEN_VALIDITY_START
	delete browser.OAUTH_ACCESS_TOKEN_VALIDITY_LENGTH
	delete browser.OAUTH_REFRESH_TOKEN

requestLogIn = ->
	browser.OAUTH_ECHO_VALUE = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
	authorizationParams = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: API_OAUTH_USER_SCOPES_REQUESTED.join(),
		client_id: API_ASSIGNED_APPLICATION_ID,
		redirect_uri: API_AFTERLOGIN_REDIRECT_URL,
		state: browser.OAUTH_ECHO_VALUE
	)
	authorizationURL = 'https://www.reddit.com/api/v1/authorize?' + authorizationParams.toString()
	window.location.href = authorizationURL

# No specific logout function; simply use query parameter "logout" on any page load to logout.

export handleLogInOrLogOut = ->
	p = new URLSearchParams(window.location.search)
	switch
		# Log in request
		when p.has('login')
			requestLogIn()
		# Successful login
		when p.has('code') and p.get('state') is browser.OAUTH_ECHO_VALUE
			invalidateCredentials()
			delete browser.OAUTH_ECHO_VALUE
			browser.OAUTH_AUTH_CODE = p.get('code')
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