import errors from '../base/errors.coffee'
import { clear as clearStore } from '../ops/ops.coffee'
import credentials from './credentials.coffee'

ACCOUNT_SCOPES_ALL = [
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
	'modnote'
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

# To login on a third-party Reddit app, the user must visit the offical Reddit OAuth authentication page and confirm that they want to give that app permission to use their account. An appropriate custom URL must be created for the authentication page. An arbitrary string (`memoString`) can be passed through the authentication process and returned to the client after the login process finishes in order to e.g. rebuild local state on the client after page load.
export getLoginURL = ({ memoString, scopeArray, scopeString }) ->
	echo = Math.trunc(Number.MAX_VALUE * Math.random()) + '$' + (memoString ? '')
	localStorage['api.credentials.exchange_echo'] = echo
	url = new URL('https://www.reddit.com/api/v1/authorize') 
	url.search = new URLSearchParams
		response_type: 'code'
		duration: 'permanent'
		scope: scopeString ? scopeArray?.join(' ') ? ACCOUNT_SCOPES_ALL.join(' ')
		client_id: localStorage['api.config.client_id']
		redirect_uri: localStorage['api.config.redirect_uri']
		state: echo
	return url

# After the user completes the OAuth authentication page on reddit.com, Reddit redirects them to the URL we specify, with the result of the login attempt provided as query parameters. If these parameters exist, it signals that an login attempt is pending client-side completion and `finishPendingLogin` should be called.
export hasPendingLogin = ->
	query = new URLSearchParams(location.search)
	return query.get('code') or query.get('error')

# Complete any pending login attempt appropriately. Any login error or previously entered `memoString` from `getLoginURL` is provided in the returned object.
export finishPendingLogin = ->
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
			when 'access_denied' then throw new errors.LoginFailure({ reason: 'user-refused-login' })
			else throw new errors.LoginFailure({ reason: error })
		if !echo or echo != state
			throw new errors.LoginFailure({ reason: 'no-matching-login-attempt' })
		if code
			localStorage['api.credentials.exchange_code'] = code
			credentials.forget() # new credentials will be generated on next API request
	catch error
		errorObject = error
	return {
		error: errorObject ? null
		memoString: state?.split('$')[1]
	}

# Check whether the current credentials represent a user account (as opposed to representing a "logged out" user).
export isLoggedIn = ->
	localStorage['api.credentials.exchange_code']? or localStorage['api.credentials.exchange_token']?

# There are 3 possible states here, each corresponding to one stage of the login process.
# 1. `logged-out`: No account is being used.
# 2. `pending`: The user has requested a login, been redirected to the OAuth page on reddit.com, and subsequently been transferred back to the third-party app to complete authentication. Note that this process can be initiated both from logged-in and logged-out states.
# 3. `logged-in`: The login process has completed successfully and the user is now logged in.
export getLoginStatus = ->
	switch
		when hasPendingLogin()
			return 'pending'
		when isLoggedIn()
			return 'logged-in'
		else
			return 'logged-out'

# Upon logging in, the API does not directly provide the account's username. For convenience, an arbitrary string (e.g. the username) can be manually associated with the current set of account credentials. This will then persist until the credentials are cleared (via logout or otherwise).
export setUser = (name) -> localStorage['api.credentials.associated_name'] = name

# Used after `setUser` to retrieve the string associated with the currently active account credentials.
export getUser = -> localStorage['api.credentials.associated_name'] ? null

# Simple compared to the login flow. We just need to delete any local account credentials and privileged data. In the interests of cleaning up after ourselves, we also proactively ask the API to void those credentials instead of just letting them expire. 
export logout = ->
	try fetch 'https://www.reddit.com/api/v1/revoke_token',
		method: 'POST'
		headers:
			Authorization: 'Basic ' + btoa(localStorage['api.config.client_id'] + ':') # HTTP Basic Auth
		body: new URLSearchParams
			token: localStorage['api.credentials.exchange_token']
			token_type_hint: 'refresh_token'
	catch error # revocation request is best effort only, doesn't matter if the network request fails
	credentials.forget()
	clearStore()