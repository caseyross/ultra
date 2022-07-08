import credentials from './infra/credentials.coffee'
import errors from './infra/errors.coffee'
import { deleteCachedData } from './operations.coffee'

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

# There are 3 possible states here, each corresponding to one stage of the login process.
# 1. `logged-out`: No account is being used.
# 2. `pending`: The user has requested a login, been redirected to the OAuth page on reddit.com, and subsequently been transferred back to the third-party app to complete authentication.
# 3. `logged-in`: The login process has completed successfully and the user is now logged in.  
export getLoginStatus = ->
	query = new URLSearchParams(location.search)
	if query.get('code') or query.get('error')
		return 'pending'
	else if localStorage['api.credentials.exchange_code'] or localStorage['api.credentials.exchange_token']
		return 'logged-in'
	else
		return 'logged-out'

# To login on a third-party Reddit app, the user must visit the offical Reddit OAuth authentication page and confirm that they want to give that app permission to use their account. We must construct and return the appropriate custom URL for the authentication page. An arbitrary string (`memoString`)can be passed through the authentication process and returned to the client after the login process finishes in order to e.g. rebuild local state on the client after page load.
export getLoginURL = (memoString) ->
	echo = Math.trunc(Number.MAX_VALUE * Math.random()) + '$' + memoString
	localStorage['api.credentials.exchange_echo'] = echo
	url = new URL('https://www.reddit.com/api/v1/authorize') 
	url.search = new URLSearchParams
		response_type: 'code'
		duration: 'permanent'
		scope: ALL_SCOPES.join()
		client_id: localStorage['api.config.client_id']
		redirect_uri: localStorage['api.config.redirect_uri']
		state: echo
	return url

# After the user completes the OAuth authentication page on reddit.com, Reddit redirects them to the URL we specify, with the result of the authentication attempt provided as query parameters. We check the parameters and finish the login attempt appropriately. Any login error or previously entered `memoString` from `getLoginURL` is provided in the returned object.
export handlePendingLogin = ->
	# Get login parameters.
	echo = localStorage['api.credentials.exchange_echo']
	query = new URLSearchParams(location.search)
	code = query.get('code') ? null # if present and no other problems, login succeeded
	error = query.get('error') ? null # if present, login failed
	state = query.get('state') ? null # must match what was sent to login page
	# Cleanup login parameters
	delete localStorage['api.credentials.exchange_echo'] # should not be used twice
	url = new URL(location.href) # clone
	url.hash = '' # server adds an extraneous fragment
	newQuery = new URLSearchParams(url.search)
	newQuery.delete('code')
	newQuery.delete('error')
	newQuery.delete('state')
	url.search = newQuery
	history.replaceState(null, null, url) # remove login parameters from URL
	# Evaluate result of login attempt.
	try
		if error then switch error
			when 'access_denied' then throw new errors.LoginFailedError({ reason: 'user-refused-login' })
			else throw new errors.LoginFailedError({ reason: error })
		if !echo or echo != state
			throw new new errors.LoginFailedError({ reason: 'no-matching-login-attempt' })
		if code
			localStorage['api.credentials.exchange_code'] = code
			credentials.forget() # new credentials will be generated on next API request
	catch error
		errorObject = error
	return {
		error: errorObject ? null
		memoString: state?.split('$')[1]
	}

# Simple compared to the login flow. We just need to delete any local account credentials and privileged data. In the interests of being a good Reddit citizen, we also ask the API server to revoke those credentials on their side. 
export logout = ->
	credentials.forget()
	deleteCachedData()
	try fetch 'https://www.reddit.com/api/v1/revoke_token',
		method: 'POST'
		headers:
			Authorization: 'Basic ' + btoa(localStorage['api.config.client_id'] + ':') # HTTP Basic Auth
		body: new URLSearchParams
			token: localStorage['api.credentials.exchange_token']
			token_type_hint: 'refresh_token'
	catch error # revocation request is best effort only, doesn't matter if the network request fails