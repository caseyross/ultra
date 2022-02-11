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