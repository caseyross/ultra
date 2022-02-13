import { invalidateCredentials } from '../infra/credentials.coffee'
import { API_REGISTERED_POSTAUTH_URL } from '../config.js'
import { API_CLIENT_ID } from '../config-obscured.js'

export default ->
	params = new URLSearchParams(location.search)
	switch
		when params.has 'login'
			# NOTE: Echo value ("state") is returned verbatim by the login endpoint.
			# It protects our client against completing auth requests started by others.
			# Additionally, it provides an easy way to retain application state through the login process (for example, which page the user was on).
			localStorage['api.credentials.exchange.echo'] = location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
			location.href = 'https://www.reddit.com/api/v1/authorize?' + new URLSearchParams {
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
		when params.has 'code' and params.has 'state'
			if params.get('state') is localStorage['api.credentials.exchange.echo']
				delete localStorage['api.credentials.exchange.echo']
				localStorage['api.credentials.exchange.auth_code'] = params.get('code')
				invalidateCredentials()
				history.replaceState {}, '', location.origin + params.get('state').split('*')[0]
		when params.has 'error'
			alert params.get('error')
		when params.has 'logout'
			invalidateCredentials()
			location.href = location.origin + location.pathname