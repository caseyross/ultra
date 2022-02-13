import { expireCurrentCredentials } from '../infra/credentials.coffee'
import { API_REGISTERED_POSTAUTH_URL } from '../config.js'
import { API_CLIENT_ID } from '../config-obscured.js'

export goToAccountAuthorizationPage ->
	# NOTE: Echo value ("state") is returned verbatim by the login endpoint.
	# It protects our client against completing auth requests started by others.
	# Additionally, it provides an easy way to retain application state through the login process (for example, which page the user was on).
	localStorage['api.credentials.exchange.echo'] = Math.trunc(Number.MAX_VALUE * Math.random()) + '///' + location
	redditAuthURL = new URL('https://www.reddit.com/api/v1/authorize') 
	redditAuthURL.search = new URLSearchParams {
		response_type: 'code'
		duration: 'permanent'
		scope: [
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
		].join()
		client_id: API_CLIENT_ID
		redirect_uri: API_REGISTERED_POSTAUTH_URL
		state: localStorage['api.credentials.exchange.echo']
	}
	location.assign(redditAuthURL)

# After the user authenticates on reddit.com, reddit redirects them to our specified client URL. The results of the login attempt are provided to the client in URL query parameters.
export processAccountAuthorizationResult ->
	if localStorage['api.credentials.exchange.echo']?
		p = new URLSearchParams(location.search)
		if localStorage['api.credentials.exchange.echo'] == p.get('state')
			delete localStorage['api.credentials.exchange.echo']
			originatingURL = p.get('state').split('///')[1]
			if p.has('error')
				# Load client as normal, but alert user of login failure.
				if p.get('error') is 'access_denied'
					alert("Couldn't login - no permissions granted.") # TODO: Better UI for this
				else
					alert("Couldn't login - unknown reason.")
			else if p.has('code')
				localStorage['api.credentials.exchange.auth_code'] = p.get('code')
				expireCurrentCredentials()
			history.replaceState({}, '', originatingURL)

export processAccountDeauthorization ->
	expireCurrentCredentials()
	location.reload() # TODO: Don't reload the whole document, just throw away all cached API data and have it reloaded
	# TODO: UI to show confirmation that user is now logged out