import RedditDataModel from './RedditDataModel.coffee'
import { get, post } from './internals/request.coffee'
import { invalidateCredentials } from './internals/authentication.coffee'
import { API_ASSIGNED_APPLICATION_ID } from '../../../config/obscured.js'
import { API_AFTERLOGIN_REDIRECT_URL, API_OAUTH_USER_SCOPES_REQUESTED } from '../../../config/api.js'

export isLoggedIn = ->
	if browser.OAUTH_REFRESH_TOKEN
		true
	else
		false

requestLogin = ->
	browser.OAUTH_ECHO_VALUE = window.location.pathname + '*' + Math.trunc(Number.MAX_VALUE * Math.random())
	authorizationParams = new URLSearchParams(
		response_type: 'code',
		duration: 'permanent',
		scope: API_OAUTH_USER_SCOPES_REQUESTED.join(),
		client_id: API_ASSIGNED_APPLICATION_ID,
		redirect_uri: API_AFTERLOGIN_REDIRECT_URL,
		state: browser.OAUTH_ECHO_VALUE
	)
	authorizationURL = 'https://www.reddit.com/api/v1/authorize?' + authorizationParams.toString()
	window.location.href = authorizationURL

# No specific logout function; simply use query parameter "logout" on any page load to logout.

export processLoginOrLogout = ->
	p = new URLSearchParams(window.location.search)
	switch
		# Login request
		when p.has('login')
			requestLogin()
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

export fetchPopularSubreddits = ->
	get
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		subreddits.filter (s) ->
			s.name isnt 'home'

export fetchCurrentUserInformation = ->
	get
		endpoint: '/api/v1/me'

export fetchCurrentUserSubscriptions = ->
	get
		endpoint: '/subreddits/mine/subscriber'
		limit: 1000
		automodel: true # Array[Subreddit]

export fetchUserInformation = (name) ->
	get
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
		endpoint: '/r/' + name + '/about'
		cache: 'r/' + name + '/information'
		automodel: true # Subreddit

export fetchSubredditEmojis = (name) ->
	get
		endpoint: '/api/v1/' + name + '/emojis/all'
		cache: 'r/' + name + '/emojis'
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
		endpoint: '/r/' + name + '/api/widgets'
		cache: 'r/' + name + '/widgets'
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
		endpoint: '/comments/' + id.toShortId()
		cache: id
	.then ([x, y]) ->
		# The post's comments are handled separately.
		new RedditDataModel(x)[0] # Post

export fetchPostComments = (id, sort = 'top') ->
	get
		endpoint: '/comments/' + id.toShortId()
		sort: sort
		cache: id
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