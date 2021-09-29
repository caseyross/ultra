import { REDDIT_APP_ID } from '../config/api-config-obscured.js'

waitForRenewal = (f) -> if LS.RENEWING then setTimeout(waitForRenewal, 20, f) else f()
forceNewRenewal = (f) -> if LS.RENEWING then delete LS.RENEWING; f(renewKey()) else f()
export renewKey = ->
	if LS.RENEWING
		return Promise.race([
			new Promise (f) -> waitForRenewal(f)
			new Promise (f) -> setTimeout(forceNewRenewal, 1000 * (3 + Math.random() * 11), f)
		])
	LS.RENEWING = yes
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(REDDIT_APP_ID + ':')
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
		delete LS.RENEWING

export finishLogin = (voucher, redirect_path) ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(REDDIT_APP_ID + ':')
		body: new URLSearchParams
			grant_type: 'authorization_code'
			code: voucher
			redirect_uri: REDDIT_LOGIN_CALLBACK_URL
	.then (response) -> response.json()
	.then (json) ->
		LS.keyType = json.token_type
		LS.keyVal = json.access_token
		LS.keyExp = (1000 * json.expires_in) + Date.now()
		LS.userKey = json.refresh_token