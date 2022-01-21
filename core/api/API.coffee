import { getCredentialsTimeLeft, renewCredentials } from './internals/authentication.coffee'
import {} from './internals/parsing.coffee'
import { countRatelimit, getRatelimitStatus, RatelimitError } from './internals/ratelimit.coffee'

request = ({ method, path, body }) ->
	# Check credentials validity. Force renewal if necessary.
	if getCredentialsTimeLeft() <= 0
		await renewCredentials()
	# Check ratelimit status and fail if quota has been hit.
	{ quota, used } = getRatelimitStatus()
	if used >= quota
		return Promise.reject(new RatelimitError())
	# OK to send.
	countRatelimit(1)
	return fetch 'https://oauth.reddit.com' + path, {
		method
		headers:
			'Authorization': browser.OAUTH_ACCESS_TOKEN
		body
	}
	.then (response) ->
		response.json()
	.finally ->
		# Asynchronously renew credentials if they're going to expire within a certain time.
		if getCredentialsTimeLeft() < Date.minutes(30)
			renewCredentials()
get = ({ endpoint, ...options }) ->
	for name, value of options
		if value == undefined or value == null
			delete options[name]
	options.raw_json = 1 # Opt out of legacy Reddit response encoding
	$loading[key] = true
	request
		method: 'GET'
		path: endpoint + '?' + (new URLSearchParams(options)).toString()
	.then (json) ->
		$vintage[key] = Date.now()
		$loading[key] = false
post = ({ endpoint, ...content }) ->
	for name, value of options
		if value == undefined or value == null
			delete options[name]
	request
		method: 'POST'
		path: endpoint
		body: new URLSearchParams(content)

export isLoggedIn = ->
	if browser.OAUTH_REFRESH_TOKEN
		true
	else
		false

export fetchPopularSubreddits = ->
	getListing
		key: 'popularsubreddits'
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		subreddits.filter (s) ->
			s.name isnt 'home'

export fetchCurrentUserInformation = ->
	getSingleton
		key: 'currentuserinfo'
		endpoint: '/api/v1/me'

export fetchCurrentUserSubscriptions = ->
	get
		key: 'currentusersubscriptions'
		endpoint: '/subreddits/mine/subscriber'
		limit: 1000
		automodel: true # Array[Subreddit]

export fetchUserInformation = (name) ->
	get
		key: 'userinfo_' + name
		endpoint: '/user/' + name + '/about'
		cache: 'u/' + name + '/about'
		automodel: true # User

export fetchUserPosts = (name, amount, { sort = 'new' }) ->
	get
		endpoint: '/user/' + name + '/posts'
		limit: amount
		sort: sort.split('/')[0]
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['u', name, filter, sort, amount].join('/')
		automodel: true # Array[Post]

export fetchUserComments = (name, amount, { sort = 'new' }) ->
	get
		endpoint: '/user/' + name + '/comments'
		limit: amount
		sort: sort.split('/')[0]
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['u', name, filter, sort, amount].join('/')
		automodel: true # Array[Comment]

export fetchUserPostsAndComments = (name, amount, { sort = 'new' }) ->
	get
		endpoint: '/user/' + name + '/overview'
		limit: amount
		sort: sort.split('/')[0]
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['u', name, filter, sort, amount].join('/')
		automodel: true # Array[Post/Comment]

export fetchSubredditInformation = (name) ->
	get
		key: 'srinfo_' + name
		endpoint: '/r/' + name + '/about'
		automodel: true # Subreddit

export fetchSubredditEmojis = (name) ->
	get
		key: 'sremojis_' + name
		endpoint: '/api/v1/' + name + '/emojis/all'
	.then (x) ->
		emojis = []
		for category of x
			# TODO: store snoomojis as well
			if category isnt 'snoomojis'
				for emoji of x[category]
					[ _, _, _, id, name ] = x[category][emoji].url.split('/')
					emojis.push(name + ':' + id)
		if emojis.length
			browser['emojis@' + name] = emojis.join(',')

export fetchSubredditWidgets = (name) ->
	get
		key: 'srwidgets_' + name
		endpoint: '/r/' + name + '/api/widgets'
	.then (x) ->
		widgets =
			basics: x.items[x.layout.idCardWidget]
			moderators: x.items[x.layout.moderatorWidget] # list of mods, not always publicly visible 
			topbar: x.layout.topbar.order.map (id) -> x.items[id]
			sidebar: x.layout.sidebar.order.map (id) -> x.items[id]
		console.log widgets

export fetchSubredditPosts = (name, amount, { sort = 'hot' }) ->
	get
		endpoint: '/r/' + name + '/' + sort.split('/')[0]
		limit: amount
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r', name, sort, amount].join('/')
		automodel: true # Array[Post]

export fetchMultiredditPosts = (namespace, name, amount, { sort = 'hot' }) ->
	if namespace is 'r'
		fetchSubredditPosts(name, amount, { sort })
	else
		get
			endpoint: '/api/multi/u/' + namespace + '/m/' + name + '/' + sort.split('/')[0]
			limit: amount
			t: sort.split('/')[1]
			sr_detail: true
			cache: ['m', namespace, name, sort, amount].join('/')
			automodel: true # Array[Post]
		.then (x) ->
			console.log x

export fetchFrontpagePosts = (amount, { sort = 'best' }) ->
	get
		endpoint: '/' + sort.split('/')[0]
		limit: amount
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r/frontpage', sort, amount].join('/')
		automodel: true # Array[Post]

export fetchPost = (id) ->
	get
		key: id
		endpoint: '/comments/' + id.toShortId()
	.then ([x, y]) ->
		# The post's comments are handled separately.
		new RedditDataModel(x)[0] # Post

export fetchPostComments = (id, sort = 'top') ->
	get
		key: 'postcomments_' + id
		endpoint: '/comments/' + id.toShortId()
		sort: sort
	.then ([x, y]) ->
		new RedditDataModel(y) # Array[Comment/CompressedComments/DeeperComments]

export fetchCompressedComments = (postId, commentIds) ->
	get
		endpoint: '/api/morechildren'
		link_id: postId
		children: commentIds

export sendUpvote = (id) ->
	post
		endpoint: '/api/vote'
		id: id
		dir: 1

export sendUnvote = (id) ->
	post
		endpoint: '/api/vote'
		id: id
		dir: 0

export sendDownvote = (id) ->
	post
		endpoint: '/api/vote'
		id: id
		dir: -1

export sendSave = (id) ->
	post
		endpoint: '/api/save'
		id: id

export sendUnsave = (id) ->
	post
		endpoint: '/api/unsave'
		id: id