import { REDDIT_CLIENT_ID } from './config.coffee'

waitForRenewal = (f) -> if LS.renewalPending then setTimeout(waitForRenewal, 20, f) else f()
forceNewRenewal = (f) -> if LS.renewalPending then delete LS.renewalPending; f(renewKey()) else f()
export renewKey = ->
	if LS.renewalPending
		return Promise.race([
			new Promise (f) -> waitForRenewal(f)
			new Promise (f) -> setTimeout(forceNewRenewal, 1000 * (3 + Math.random() * 11), f)
		])
	LS.renewalPending = yes
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(REDDIT_CLIENT_ID + ':')
		body:
			if LS.userKey
				new URLSearchParams
					grant_type: 'refresh_token'
					refresh_token: LS.userKey
			else
				new URLSearchParams
					grant_type: 'https://oauth.reddit.com/grants/installed_client'
					device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	.then (response) -> response.json()
	.then (json) ->
		LS.keyType = json.token_type
		LS.keyVal = json.access_token
		LS.keyExp = (1000 * json.expires_in) + Date.now()
	.finally ->
		delete LS.renewalPending