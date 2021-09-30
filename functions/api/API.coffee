



export getSubscribedSubreddits = ->
	API.get
		endpoint: '/subreddits/mine/subscriber'
		limit: 100
		automodel: true # Array[Subreddit]
export getPopularSubreddits = ->
	API.get
		endpoint: '/subreddits/popular'
		automodel: true # Array[Subreddit]
	.then (subreddits) -> subreddits.filter (s) -> s.name isnt 'home'


export getAccountInfo = ->
	API.get
		endpoint: '/api/v1/me'
export getUserInfo = (name) ->
	API.get
		endpoint: '/user/' + name + '/about'
		cache: 'u/' + name + '/about'
		automodel: true # User
export getSubredditInfo = (name) ->
	API.get
		endpoint: '/r/' + name + '/about'
		cache: 'r/' + name + '/information'
		automodel: true # Subreddit
export getSubredditEmojis = (name) ->
	API.get
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
			LS['emojis@' + name] = emojis.join(',')
export getSubredditWidgets = (name) ->
	API.get
		endpoint: '/r/' + name + '/api/widgets'
		cache: 'r/' + name + '/widgets'
	.then (x) ->
		widgets =
			basicInfo: x.items[x.layout.idCardWidget]
			moderators: x.items[x.layout.moderatorWidget]
			topbar: x.layout.topbar.order.map (id) -> x.items[id]
			sidebar: x.layout.sidebar.order.map (id) -> x.items[id]
		console.log widgets


export getUserSubmissions = (name, { filter = 'overview', sort = 'new', quantity }) ->
	API.get
		endpoint: '/user/' + name + '/' + filter
		limit: quantity
		sort: sort.split('/')[0]
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['u', name, filter, sort, quantity].join('/')
		automodel: true # Array[Post/Comment]
export getSubredditPosts = (name, { sort = 'hot', quantity }) ->
	API.get
		endpoint: '/r/' + name + '/' + sort.split('/')[0]
		limit: quantity
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r', name, sort, quantity].join('/')
		automodel: true # Array[Post]
export getMultiredditPosts = (namespace, name, { sort = 'hot', quantity }) ->
	if namespace is 'r'
		getSubredditPosts(name, { sort, quantity })
	else
		API.get
			endpoint: '/api/multi/u/' + namespace + '/m/' + name + '/' + sort.split('/')[0]
			limit: quantity
			t: sort.split('/')[1]
			sr_detail: true
			cache: ['m', namespace, name, sort, quantity].join('/')
			automodel: true # Array[Post]
		.then (x) -> console.log x
export getFrontpagePosts = ({ sort = 'best', quantity }) ->
	API.get
		endpoint: '/' + sort.split('/')[0]
		limit: quantity
		t: sort.split('/')[1]
		sr_detail: true
		cache: ['r/frontpage', sort, quantity].join('/')
		automodel: true # Array[Post]


export getPost = (id) ->
	API.get
		endpoint: '/comments/' + id
		cache: 't3_' + id
	.then ([x, y]) ->
		# The post's comments are handled separately.
		new Listing(x)[0] # Post
export getPostComments = (id) ->
	API.get
		endpoint: '/comments/' + id
		cache: 't3_' + id
	.then ([x, y]) ->
		new Listing(y) # Array[Comment/MoreComments]
export getMoreComments = (postId, commentIds) ->
	API.get
		endpoint: '/api/morechildren'
		link_id: 't3_' + postId
		children: commentIds


export upvote = (fullname) ->
	API.post
		endpoint: '/api/vote'
		id: fullname
		dir: 1
export upvote = (fullname) ->
	API.post
		endpoint: '/api/vote'
		id: 't1_' + this.id
		dir: 0
export upvote = (fullname) ->
	API.post
		endpoint: '/api/vote'
		id: 't1_' + this.id
		dir: -1
export upvote = (fullname) ->
	API.post
		endpoint: '/api/save'
		id: 't1_' + this.id
export upvote = (fullname) ->
	API.post
		endpoint: '/api/unsave'
		id: 't1_' + this.id
export upvote = (fullname) ->
	API.post
		endpoint: '/api/hide'
		id: 't1_' + this.id
export upvote = (fullname) ->
	API.post
		endpoint: '/api/unhide'
		id: 't1_' + this.id
