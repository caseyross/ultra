import { Time } from '../../utils/index.js'
import errors from '../errors.coffee'
import ratelimit from './ratelimit.coffee'

waitForRenew = (f) ->
	if localStorage['api.credentials.renewing'] is 'TRUE'
		return setTimeout(waitForRenew, 20, f)
	return f()
forceRenew = (f) ->
	if localStorage['api.credentials.renewing'] is 'TRUE'
		localStorage['api.credentials.renewing'] = 'FALSE'
		return f(credentials.renew())
	return f()

credentials = {

	forget: ->
		delete localStorage['api.credentials.exchange_token']
		delete localStorage['api.credentials.key_expiry']
		delete localStorage['api.credentials.key']
		ratelimit.forget()

	renew: ->
		# In the event that multiple instances of the application are instantiated simultaneously, we don't want them competing to acquire the credentials, which are shared.
		if localStorage['api.credentials.renewing'] is 'TRUE'
			return Promise.race([
				new Promise (f) -> waitForRenew(f)
				new Promise (f) -> setTimeout(forceRenew, Time.sToMs(3 + 11 * Math.random()), f)
			])
		# The quickest instance takes out a lock on the renewal process. If it fails to complete it in a reasonable time, another instance force-resets the lock and takes its place.
		localStorage['api.credentials.renewing'] = 'TRUE'
		# Reddit uses (mostly standard) OAuth 2 for authentication. (https://github.com/reddit-archive/reddit/wiki/OAuth2)
		exchange_code = localStorage['api.credentials.exchange_code']
		delete localStorage['api.credentials.exchange_code'] # no reuse allowed
		exchange_token = localStorage['api.credentials.exchange_token']
		body = new URLSearchParams(switch
			when exchange_code # New account login
				{
					grant_type: 'authorization_code'
					code: exchange_code
					redirect_uri: localStorage['api.config.redirect_uri']
				}
			when exchange_token # Existing login, but credentials expired
				{
					grant_type: 'refresh_token'
					refresh_token: exchange_token
				}
			else # Logged-out credentials
				{
					grant_type: 'https://oauth.reddit.com/grants/installed_client'
					device_id: 'DO_NOT_TRACK_THIS_DEVICE' # required field, but Reddit allows this value as an option
				}
		)
		config =
			method: 'POST'
			headers:
				Authorization: 'Basic ' + btoa(localStorage['api.config.client_id'] + ':') # HTTP Basic Auth
			body: body
		return fetch('https://www.reddit.com/api/v1/access_token', config)
		.catch (error) ->
			# NOTE: a TypeError here means that either the network request failed OR the fetch config was structured badly. `fetch` does not distinguish between these errors, so we make the assumption that the config was OK.
			if error instanceof TypeError then throw new errors.ServerConnectionFailedError({ cause: error })
			throw error
		.then (response) ->
			response.json()
		.then (data) ->
			if data.token_type? and data.access_token? and Number.isFinite(Number data.expires_in)
				localStorage['api.credentials.key'] = "#{data.token_type} #{data.access_token}"
				localStorage['api.credentials.key_expiry'] = Time.epochMs() + Time.sToMs(data.expires_in)
				if data.refresh_token? then localStorage['api.credentials.exchange_token'] = data.refresh_token
		.finally ->
			localStorage['api.credentials.renewing'] = 'FALSE'
			if not credentials.valid then throw new errors.CredentialsRequiredError({ message: 'failed to acquire valid credentials' })

}

Object.defineProperty(credentials, 'valid', {
	get: ->
		key = localStorage['api.credentials.key']
		expiry = Number localStorage['api.credentials.key_expiry']
		if key? and Number.isFinite(expiry) then return expiry - Time.epochMs() > 0
		return false
})

export default credentials