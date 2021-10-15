import { get, post } from './primitives/request.coffee'
import Listing from '../../models/Listing.coffee'

export fetchMyInfo = ->
	get
		endpoint: '/api/v1/me'

export fetchUserInfo = (name) ->
	get
		endpoint: '/user/' + name + '/about'
		cache: 'u/' + name + '/about'
		automodel: true # User

export fetchSubredditInfo = (name) ->
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
			Storage['emojis@' + name] = emojis.join(',')

export fetchSubredditWidgets = (name) ->
	get
		endpoint: '/r/' + name + '/api/widgets'
		cache: 'r/' + name + '/widgets'
	.then (x) ->
		widgets =
			basicInfo: x.items[x.layout.idCardWidget]
			moderators: x.items[x.layout.moderatorWidget] # list of mods, only available via API for other mods 
			topbar: x.layout.topbar.order.map (id) -> x.items[id]
			sidebar: x.layout.sidebar.order.map (id) -> x.items[id]
		console.log widgets

export fetchUserSubmissions = (name, { filter = 'overview', sort = 'new', quantity }) ->
	get
		endpoint: '/user/' + name + '/' + filter
		limit: quantity
		sort: sort.split('/')[0]
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['u', name, filter, sort, quantity].join('/')
		automodel: true # Array[Post/Comment]

export fetchSubredditPosts = (name, { sort = 'hot', quantity }) ->
	get
		endpoint: '/r/' + name + '/' + sort.split('/')[0]
		limit: quantity
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r', name, sort, quantity].join('/')
		automodel: true # Array[Post]

export fetchMultiredditPosts = (namespace, name, { sort = 'hot', quantity }) ->
	if namespace is 'r'
		fetchSubredditPosts(name, { sort, quantity })
	else
		get
			endpoint: '/api/multi/u/' + namespace + '/m/' + name + '/' + sort.split('/')[0]
			limit: quantity
			t: sort.split('/')[1]
			sr_detail: true
			cache: ['m', namespace, name, sort, quantity].join('/')
			automodel: true # Array[Post]
		.then (x) ->
			console.log x

export fetchFrontpagePosts = ({ sort = 'best', quantity }) ->
	get
		endpoint: '/' + sort.split('/')[0]
		limit: quantity
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r/frontpage', sort, quantity].join('/')
		automodel: true # Array[Post]

export fetchPost = (id) ->
	get
		endpoint: '/comments/' + id.toShortId()
		cache: id
	.then ([x, y]) ->
		# The post's comments are handled separately.
		new Listing(x)[0] # Post

export fetchPostComments = (id) ->
	get
		endpoint: '/comments/' + id.toShortId()
		cache: id
	.then ([x, y]) ->
		new Listing(y) # Array[Comment/MoreComments]

export fetchMoreComments = (postId, commentIds) ->
	get
		endpoint: '/api/morechildren'
		link_id: postId
		children: commentIds

export fetchPopularSubreddits = ->
	get
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) ->
		subreddits.filter (s) ->
			s.name isnt 'home'

export fetchMySubscribedSubreddits = ->
	get
		endpoint: '/subreddits/mine/subscriber'
		limit: 100
		automodel: true # Array[Subreddit]

export sendVote = (id, vote) ->
	post
		endpoint: '/api/vote'
		id: id
		dir: vote # 1/0/-1

export sendSave = (id) ->
	post
		endpoint: '/api/save'
		id: id

export sendUnsave = (id) ->
	post
		endpoint: '/api/unsave'
		id: id