import errors from './errors.coffee'

ALL_SCOPES = [
	'account'
	'creddits'
	'edit'
	'flair'
	'history'
	'identity'
	'livemanage'
	'modconfig'
	'modcontributors'
	'modflair'
	'modlog'
	'modmail'
	'modothers'
	'modposts'
	'modself'
	'modwiki'
	'mysubreddits'
	'privatemessages'
	'read'
	'report'
	'save'
	'structuredstyles'
	'submit'
	'subscribe'
	'vote'
	'wikiedit'
	'wikiread'
]

# To login, the user must confirm on Reddit's offical authentication page that they want to give access to our app.
# We need to construct the appropriate query params for the authentication page URL, and then send the user there.
export requestLogin = ->
	echo = Math.trunc(Number.MAX_VALUE * Math.random()) + '///' + location
	localStorage['api.credentials.exchange.echo'] = echo
	loginUrl = new URL('https://www.reddit.com/api/v1/authorize') 
	loginUrl.search = new URLSearchParams {
		response_type: 'code'
		duration: 'permanent'
		scope: ALL_SCOPES.join()
		client_id: localStorage['api.config.client_id']
		redirect_uri: localStorage['api.config.redirect_uri']
		state: echo
	}
	location.assign(loginUrl)

# After the user completes the OAuth authentication page on reddit.com, Reddit redirects them to the URL we specify, with the result of the authentication attempt provided as query parameters.
# The client must check the parameters and finish the login attempt appropriately.
export processLoginResult = ->
	# Check for previously set echo value.
	if localStorage['api.credentials.exchange.echo']?
		echo = localStorage['api.credentials.exchange.echo']
		delete localStorage['api.credentials.exchange.echo']
	else
		throw new errors.LoginFailedError({ reason: 'no-matching-login-attempt' })
	p = new URLSearchParams(location.search)
	# Get login result query parameters.
	state = p.get('state') ? null # must match what was sent to login page
	error = p.get('error') ? null # if present, login failed
	code = p.get('code') ? null # if present and no other problems, login succeeded
	# Clean up URL.
	if state
		originatingURL = state.split('///')[1]
		history.replaceState({}, '', originatingURL)
	# Check login result.
	if state == echo
		if error
			if error is 'access_denied'
				throw new errors.LoginFailedError({ reason: 'user-refused-login' })
			else if typeof error is 'string'
				throw new errors.LoginFailedError({ reason: error })
			else
				throw new errors.LoginFailedError({ reason: 'unknown' })
		else if code
			localStorage['api.credentials.exchange.auth_code'] = code
			# Delete our current credentials. New ones will be generated for the new account, using the auth code.
			deleteLocalCredentials()

# Simple compared to logins. We just need to delete the account credentials and any privileged data locally. We also tell Reddit to revoke the credentials on the server side, to help with their book-keeping.
export logout = ->
	deleteLocalCredentials()
	fetch 'https://www.reddit.com/api/v1/revoke_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(localStorage['api.config.client_id'] + ':') # HTTP Basic Auth
		body: new URLSearchParams
			token_type_hint: 'refresh_token'
			token: localStorage['api.credentials.exchange.token']
	location.reload() # TODO: Don't reload the whole document, just throw away all cached API data and have it reloaded

deleteLocalCredentials = ->
	delete localStorage['api.credentials.exchange.token']
	delete localStorage['api.credentials.key.expiration']
	delete localStorage['api.credentials.key.token']