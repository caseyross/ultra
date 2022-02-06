import { invalidateCredentials } from './credentials.coffee'
import { API_POSTLOGIN_REDIRECT } from '../../../config/config.js'
import { API_APPLICATION_ID } from '../../../config/obscured.js'

export handleLoginOrLogout = ->
	p = new URLSearchParams(window.location.search)
	switch
		# Log in request
		when p.has('login')
			browser.OAUTH_ECHO_VALUE = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
			authorizationParams = new URLSearchParams {
				response_type: 'code'
				duration: 'permanent'
				scope: [
					'edit',
					'flair',
					'history',
					'identity',
					'mysubreddits',
					'privatemessages',
					'read',
					'report',
					'save',
					'structuredstyles',
					'submit',
					'subscribe',
					'vote',
					'wikiread'
				].join()
				client_id: API_APPLICATION_ID
				redirect_uri: API_POSTLOGIN_REDIRECT
				state: browser.OAUTH_ECHO_VALUE
			}
			authorizationURL = 'https://www.reddit.com/api/v1/authorize?' + authorizationParams.toString()
			window.location.href = authorizationURL
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
