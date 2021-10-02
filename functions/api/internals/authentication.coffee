import { CLIENT_ID } from '../config/api-config-obscured.js'
import { REDIRECT_URI, SCOPES } from '../config/api-config.js'

export credentialsValidAt = (timestamp) ->
	return Storage.ACCESS_TOKEN and Number(Storage.ACCESS_TOKEN_VALID_UNTIL) > timestamp

export renewCredentials = ->
	# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
	if Storage.CREDENTIALS_RENEWAL_IN_PROGRESS
		return Promise.race([
			new Promise (f) -> waitForCredentialsRenewal(f)
			new Promise (f) -> setTimeout(ensureCredentialsRenewal, Date.seconds(3 + 11 * Math.random()), f)
		])
	# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
	Storage.CREDENTIALS_RENEWAL_IN_PROGRESS = true
	# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
	return fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			# HTTP Basic Auth
			'Authorization': 'Basic ' + btoa(CLIENT_ID + ':')
		body: new URLSearchParams(
			switch
				# Request for credentials for a user who just authorized our application.
				when Storage.CREDENTIALS_VOUCHER
					{
						grant_type: 'authorization_code'
						code: Storage.CREDENTIALS_VOUCHER
						redirect_uri: REDIRECT_URI
					}
				# Request for credentials for a user who's already "logged in".
				when Storage.REFRESH_TOKEN
					{
						grant_type: 'refresh_token'
						refresh_token: Storage.REFRESH_TOKEN
					}
				# Request for null-user credentials.
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
			Storage.ACCESS_TOKEN_VALID_UNTIL = Date.now() + Date.seconds(response.expires_in)
			Storage.ACCESS_TOKEN = response.token_type + ' ' + response.access_token
			if response.refresh_token
				Storage.REFRESH_TOKEN = response.refresh_token
	.finally ->
		Storage.CREDENTIALS_RENEWAL_IN_PROGRESS = false

waitForCredentialsRenewal = (f) ->
	if Storage.CREDENTIALS_RENEWAL_IN_PROGRESS
		return setTimeout(waitUntilAccessTokenRenewed, 20, f)
	else
		return f()

ensureCredentialsRenewal = (f) ->
	if Storage.CREDENTIALS_RENEWAL_IN_PROGRESS
		Storage.CREDENTIALS_RENEWAL_IN_PROGRESS = false
		return f(renewCredentials())
	else
		return f()

export invalidateCredentials = ->
	delete Storage.ACCESS_TOKEN
	delete Storage.ACCESS_TOKEN_VALID_UNTIL
	delete Storage.REFRESH_TOKEN
 
export requestCredentialsVoucher = ->
	Storage.CREDENTIALS_VOUCHER_SECURITY_STRING = location.pathname + ',' + Math.trunc(Number.MAX_VALUE * Math.random())
	p = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: SCOPES.join(),
		client_id: CLIENT_ID,
		redirect_uri: REDIRECT_URI,
		state: Storage.CREDENTIALS_VOUCHER_SECURITY_STRING
	)
	location.href = 'https://www.reddit.com/api/v1/authorize?' + p.toString

export collectCredentialsVoucher = ->
	p = new URLSearchParams(location.search)
	if p.has('code') and p.get('state') is Storage.CREDENTIALS_VOUCHER_SECURITY_STRING
		delete Storage.CREDENTIALS_VOUCHER_SECURITY_STRING
		Storage.CREDENTIALS_VOUCHER = p.get('code')
		location.pathname = p.get('state').split(',')[0]
	else
		p.get('error')
			state.loginError = true