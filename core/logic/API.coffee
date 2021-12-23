import RedditDataModel from '../objects/reddit/RedditDataModel.coffee'
import { get, post } from './net/request.coffee'

export fetchPopularSubreddits = ->
	get
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		subreddits.filter (s) ->
			s.name isnt 'home'

export fetchCurrentUserProfile = ->
	get
		endpoint: '/api/v1/me'

export fetchCurrentUserSubscriptions = ->
	get
		endpoint: '/subreddits/mine/subscriber'
		limit: 1000
		automodel: true # Array[Subreddit]

export fetchUserProfile = (name) ->
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

export fetchSubredditProfile = (name) ->
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
			browserState['emojis@' + name] = emojis.join(',')

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