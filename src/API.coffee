import { cached } from './Cache.coffee'
import Model from './Model.coffee'

REDDIT_CLIENT_ID = '3-XWy138GarDUw'
REDDIT_LOGIN_REDIRECT_URI = 'https://localhost:8080/login'
REDDIT_LOGIN_AUTH_URL = (post_login_redirect_path) -> "https://www.reddit.com/api/v1/authorize?response_type=code&duration=permanent&scope=edit,flair,history,identity,mysubreddits,privatemessages,read,report,save,submit,subscribe,vote,wikiread&client_id=#{REDDIT_CLIENT_ID}&redirect_uri=#{REDDIT_LOGIN_REDIRECT_URI}&state=#{post_login_redirect_path}"


export startLogin = ->
	location.href = REDDIT_LOGIN_AUTH_URL(location.pathname + location.search)

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
			get
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


waitForRenewal = (f) -> if LS.renewalPending then setTimeout(waitForRenewal, 20, f) else f()
forceNewRenewal = (f) -> if LS.renewalPending then delete LS.renewalPending; f(renewKey()) else f()
renewKey = ->
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


class RateLimitError extends Error
	constructor: (message) ->
		super(message)
		@name = 'RateLimitError'

checkRatelimit = ->
	current = if LS.calls then LS.calls.split(',') else []
	revised = current.filter((x) -> Number(x) > Date.now())
	if revised.length > 600 then return Number(revised[0]) - Date.now() # Prohibit having > 600 requests on quota at any time.
	revised.push(Date.now() + 600000) # Requests occupy ratelimit quota space for 10 minutes after being sent.
	LS.calls = revised.join()
	return 0

call = ({ method, path, body }) ->
	if !isFinite(LS.keyExp) then await renewKey() # No key...
	if Number(LS.keyExp) < Date.now() then await renewKey() # Key expired...
	waitTime = checkRatelimit()
	if waitTime > 0
		Promise.reject(new RateLimitError("Request would exceed Reddit's API limits. Wait #{waitTime // 1000} seconds."))
	else
		fetch 'https://oauth.reddit.com' + path,
			method: method
			headers:
				'Authorization': LS.keyType + ' ' + LS.keyVal
			body: body
		.then (response) ->
			response.json()
		.finally ->
			if (Number(LS.keyExp) - Date.now()) < 3000000 then renewKey() # Try to maintain 50 minutes validity on key, to minimize forced renewals.


export get = ({ endpoint, options = {} }) ->
	for name, value of options
		if not value and value isnt 0 then delete options[name] # Delete keys with empty values.
	options.raw_json = 1
	call
		method: 'GET'
		path: endpoint + '?' + (new URLSearchParams(options)).toString()

export post = ({ endpoint, content = {} }) ->
	for name, value of content
		if not value and value isnt 0 then delete content[name] # Delete keys with empty values.
	call
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)


export getListingItems = ({ endpoint, ...options }) ->
	get
		endpoint: endpoint
		options: options
	.then (x) ->
		new Model(x)


getPopularSubreddits = ->
	getListingItems
		endpoint: '/subreddits/popular'
	.then (subreddits) ->
		LS.popularSubreddits =
			subreddits
			.filter (s) -> s.name isnt 'home'
			.map (s) -> s.displayName
			.join()

getUserSubscriptions = ->
	getListingItems
		endpoint: '/subreddits/mine/subscriber'
		limit: 100
	.then (subreddits) ->
		LS.userSubscriptions =
			subreddits
			.sort (a, b) -> if a.name < b.name then -1 else 1
			.sort (a, b) ->
				if a.name.startsWith('u_') and b.name.startsWith('u_') then return 0
				if a.name.startsWith('u_') then return 1
				if b.name.startsWith('u_') then return -1
			.map (s) -> s.displayName
			.join()


export getSubredditInformation = (subredditName) ->
	cached 'r/' + subredditName + '/information', ->
		get
			endpoint: '/r/' + subredditName + '/about'
		.then (x) ->
			new Model(x)

export getSubredditRules = (subredditName) ->
	cached 'r/' + subredditName + '/rules', ->
		get
			endpoint: '/r/' + subredditName + '/about/rules'
		.then (x) ->
			console.log x

export getSubredditSidebar = (subredditName) ->
	cached 'r/' + subredditName + '/sidebar', ->
		get
			endpoint: '/r/' + subredditName + '/about/sidebar'
		.then (x) ->
			console.log x

export getSubredditEmojis = (subredditName) ->
	if LS.userKey
		cached 'r/' + subredditName + '/emojis', ->
			get
				endpoint: '/api/v1/' + subredditName + '/emojis/all'
			.then (x) ->
				emojis = []
				for category of x
					if category isnt 'snoomojis'
						for emoji of x[category]
							[ _, _, _, id, name ] = x[category][emoji].url.split('/')
							emojis.push(name + ':' + id)
				if emojis.length
					LS['emojis@' + subredditName] = emojis.join(',')
	else
		Promise.resolve()
			
export getUserInformation = (userName) ->
	cached 'u/' + userName + '/about', ->
		get
			endpoint: '/user/' + userName + '/about'
		.then (x) ->
			new Model(x)


export getFrontpagePosts = ({ sort = 'best', quantity }) ->
	cached ['r/frontpage', sort, quantity].join('/'), ->
		getListingItems
			endpoint: '/' + sort.split('/')[0]
			limit: quantity
			t: sort.split('/')[1]

export getSubredditPosts = (subredditName, { sort = 'hot', quantity }) ->
	cached ['r', subredditName, sort, quantity].join('/'), ->
		getListingItems
			endpoint: '/r/' + subredditName + '/' + sort.split('/')[0]
			limit: quantity
			t: sort.split('/')[1]

export getMultiredditPosts = (multiredditNamespace, multiredditName, { sort = 'hot', quantity }) ->
	cached ['m', multiredditNamespace, multiredditName, sort, quantity].join('/'), ->
		if multiredditNamespace is 'r'
			getSubredditPosts(multiredditName, { sort, quantity })
		else
			getListingItems
				endpoint: '/api/multi/u' + multiredditNamespace + '/m/' + multiredditName + '/' + sort.split('/')[0]
				limit: quantity
				t: sort.split('/')[1]
			.then (x) ->
				console.log x

export getUserItems = (userName, { filter = 'overview', sort = 'new', quantity }) ->
	cached ['u', userName, filter, sort, quantity].join('/'), ->
		getListingItems
			endpoint: '/user/' + userName + '/' + filter
			limit: quantity
			sort: sort.split('/')[0]
			t: sort.split('/')[1]


export getPost = (id) ->
	cached 't3_' + id, ->
		get
			endpoint: '/comments/' + id
	.then ([x, y]) ->
		# The post's comments are handled separately via the Post constructor.
		new Model(x)[0]

export getPostComments = (id) ->
	cached 't3_' + id, ->
		get
			endpoint: '/comments/' + id
	.then ([x, y]) ->
		new Model(y)