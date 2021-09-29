import { REDDIT_APP_ID, REDDIT_LOGIN_URL, REDDIT_LOGIN_CALLBACK_URL } from '../config/api-config.js'
import API from './API.coffee'

export startLogin = -> location.href = REDDIT_LOGIN_URL { redirect: location.pathname + location.search }
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

export logout = -> 
	delete LS.keyExp
	delete LS.keyVal
	delete LS.keyType
	delete LS.userKey
	delete LS.userName
	delete LS.userPic
	delete LS.userSubreddits
	delete LS.userUsers
	location.reload()