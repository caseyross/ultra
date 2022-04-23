import credentials from './credentials.coffee'
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

# To login on a third-party Reddit app, the user must visit the offical Reddit OAuth authentication page and confirm that they want to give that app permission to use their account. We construct the appropriate custom URL for the page and transfer the user there.
export requestLogin = ->
	echo = Math.trunc(Number.MAX_VALUE * Math.random()) + '///' + location
	localStorage['api.credentials.exchange_echo'] = echo
	url = new URL('https://www.reddit.com/api/v1/authorize') 
	url.search = new URLSearchParams
		response_type: 'code'
		duration: 'permanent'
		scope: ALL_SCOPES.join()
		client_id: localStorage['api.config.client_id']
		redirect_uri: localStorage['api.config.redirect_uri']
		state: echo
	location.assign(url)

# After the user completes the OAuth authentication page on reddit.com, Reddit redirects them to the URL we specify, with the result of the authentication attempt provided as query parameters. The client must check the parameters and finish the login attempt appropriately.
export processLoginResult = ->
	# Get echo value that should have been set prior to login result.
	echo = localStorage['api.credentials.exchange_echo']
	delete localStorage['api.credentials.exchange_echo']
	# Get login result values from URL query params.
	query = new URLSearchParams(location.search)
	state = query.get('state') ? null # must match what was sent to login page
	error = query.get('error') ? null # if present, login failed
	code = query.get('code') ? null # if present and no other problems, login succeeded
	# Clean up login params in URL.
	if state then history.replaceState({}, '', state.split('///')[1])
	# Check login result.
	if not echo or echo != state then throw new errors.LoginFailedError({ reason: 'no-matching-login-attempt' })
	if error then switch
		when error is 'access_denied' then throw new errors.LoginFailedError({ reason: 'user-refused-login' })
		when typeof error is 'string' then throw new errors.LoginFailedError({ reason: error })
		else throw new errors.LoginFailedError({ reason: 'unknown' })
	if code
		localStorage['api.credentials.exchange_code'] = code
		credentials.forget() # the new credentials will be generated on next API request

# Simple compared to the login flow. We just need to delete any local account credentials and privileged data. We also tell the server to revoke those credentials, as a precaution.
export logout = ->
	credentials.forget()
	fetch 'https://www.reddit.com/api/v1/revoke_token',
		method: 'POST'
		headers:
			Authorization: 'Basic ' + btoa(localStorage['api.config.client_id'] + ':') # HTTP Basic Auth
		body: new URLSearchParams
			token: localStorage['api.credentials.exchange_token']
			token_type_hint: 'refresh_token'
	location.reload() # TODO: Don't reload the whole document, just throw away all cached API data and reload it