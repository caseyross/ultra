import { REDDIT_CLIENT_ID, REDDIT_LOGIN_AUTH_URL, REDDIT_LOGIN_REDIRECT_URI } from './config.coffee'
import API from './API.coffee'

export startLogin = -> location.href = REDDIT_LOGIN_AUTH_URL(location.pathname + location.search)
export finishLogin = (voucher, redirect_path) ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic ' + btoa(REDDIT_CLIENT_ID + ':')
		body: new URLSearchParams
			grant_type: 'authorization_code'
			code: voucher
			redirect_uri: REDDIT_LOGIN_REDIRECT_URI
	.then (response) -> response.json()
	.then (json) ->
		LS.keyType = json.token_type
		LS.keyVal = json.access_token
		LS.keyExp = (1000 * json.expires_in) + Date.now()
		LS.userKey = json.refresh_token
		Promise.all([
			API.get
				endpoint: '/api/v1/me'
			.then (user) ->
				LS.userPic = user.subreddit.icon_img
				LS.userName = user.name
			getUserSubscriptions()
		]).then ->
			history.replaceState({}, '', location.origin + redirect_path)
			location.reload()

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

getPopularSubreddits = ->
	API.get
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		LS.popularSubreddits =
			subreddits
			.filter (s) -> s.name isnt 'home'
			.map (s) -> s.displayName
			.join()
getUserSubscriptions = ->
	API.get
		endpoint: '/subreddits/mine/subscriber'
		limit: 100
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		LS.userSubreddits =
			subreddits
			.map (s) -> s.displayName
			.filter (s) -> not s.startsWith('u_')
			.join()
		LS.userUsers =
			subreddits
			.map (s) -> s.displayName
			.filter (s) -> s.startsWith('u_')
			.map (s) -> s[2..]
			.join()