GEO_SEO_PREFIXES =
	['de', 'es', 'fr', 'it', 'pt']
RECOGNIZED_TOP_LEVEL_PATH_SEGMENTS =
	['api', 'c', 'chat', 'collection', 'dev', 'domain', 'gallery', 'link', 'live', 'message', 'p', 'poll', 'post', 'prefs', 'r', 'reddits', 'report', 'search', 'submit', 'subreddit', 'subreddits', 't', 'tb', 'u', 'user', 'video', 'w', 'wiki'] # front page sort options handled separately
SORT_OPTIONS_FEED = 
	['controversial', 'hot', 'new', 'rising', 'top']
SORT_OPTIONS_FEED_FRONTPAGE =
	['best', 'controversial', 'hot', 'new', 'rising', 'top']
SORT_OPTIONS_FEED_SEARCH =
	['comments', 'relevance', 'new', 'top']
SORT_OPTIONS_FEED_USER =
	['controversial', 'hot', 'new', 'top']
SORT_OPTIONS_POST_COMMENTS =
	['confidence', 'controversial', 'new', 'old', 'qa', 'top']
TIMERANGE_OPTIONS =
	['all', 'day', 'hour', 'month', 'week', 'year']

export default (url) ->
	feed = {}
	post = {}
	wiki = {}
	external = false
	
	#
	# Parse URL query:
	#
	query = new URLSearchParams(decodeURI(url.search))
	flair_search_query = query.get('f')?.replaceAll('flair_name', 'flair')
	combined_search_query = [flair_search_query, query.get('q')].filter((x) -> x).join('+')
	combined_sanitized_search_query = combined_search_query.replaceAll(':', '=').replaceAll(' ', '+')
	feed.search_query = combined_sanitized_search_query if combined_sanitized_search_query?.length > 0
	if (query.get('sort') in SORT_OPTIONS_FEED_SEARCH and query.get('q')) or query.get('sort') in SORT_OPTIONS_FEED
		feed.sort = query.get('sort')
	feed.time_range = query.get('t') if query.get('t') in TIMERANGE_OPTIONS
	post.comments_sort = query.get('comment_sort') if query.get('comment_sort') in SORT_OPTIONS_POST_COMMENTS
	post.focus_comment_id = query.get('comment')
	post.focus_comment_parent_count = query.get('context')
	wiki.page_version = query.get('v')
	
	#
	# Parse URL path:
	#
	path = url.pathname.split('/').map((x) -> decodeURIComponent(x).replaceAll(' ', '_'))
	# Strip empty leading/trailing segments.
	if path[0] is ''
		path.shift()
	if path.at(-1) is ''
		path.pop()
	# Strip global SEO prefixes (but keep r/de).
	if path[0] in GEO_SEO_PREFIXES and path[1] is 'r' and path[2]
		path.shift()
	# Rewrite "front page" requests to conform to multireddit syntax.
	if path[0] in [...SORT_OPTIONS_FEED_FRONTPAGE]
		path = ['user', 'r', 'm', 'subscriptions', ...path]
	# Treat top-level paths as subreddit names unless we know otherwise.
	if path[0]? and path[0] not in RECOGNIZED_TOP_LEVEL_PATH_SEGMENTS
		path.unshift('r')
	# Rewrite r/all and r/popular to conform to multireddit syntax.
	if path[0] is 'r' and path[1] is 'all' or path[1] is 'popular'
		path = ['user', 'r', 'm', ...path[1..]]
	[ a, b, c, d, e, f, g ] = path
	switch a
		when 'c', 'collection'
			feed.type = 'collection_posts'
			feed.collection_id = b
		when 'message'
			external = true
		when 'p', 'post'
			post.id = b
		when 'r', 'subreddit'
			feed.subreddit_name = b
			if c is undefined or c in SORT_OPTIONS_FEED or c in ['about', 'search']
				feed.type = 'subreddit_posts'
				feed.sort = c 
			else switch c
				when 'c', 'collection'
					feed.type = 'collection_posts'
					feed.collection_id = d
				when 'comments', 'p', 'post'
					post.id = d
					post.focus_comment_id = f
					# handle overloaded "sort" on legacy post page
					delete feed.sort
					post.comments_sort = query.get('sort') if query.get('sort') in SORT_OPTIONS_POST_COMMENTS
				when 'duplicates'
					feed.type = 'duplicate_posts'
					feed.duplicate_post_id = d
				when 'submit'
					external = true
				when 'w', 'wiki'
					feed.type = 'subreddit_posts'
					wiki.subreddit_name = b
					wiki.page_name = [d, e, f, g].filter((x) -> x).join('/') or 'index'
				else
					post.id = c
		when 'u', 'user'
			feed.user_name = b
			switch c
				when undefined, 'comments', 'posts', 'submitted'
					feed.type = 'user_posts'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
				when 'downvoted'
					feed.type = 'account_downvoted_posts'
					external = true
				when 'm'
					feed.type = 'multireddit_posts'
					feed.multireddit_name = d
					feed.sort = e if e in SORT_OPTIONS_FEED
				when 'gilded'
					feed.type = 'account_gilded_posts'
					external = true
				when 'hidden'
					feed.type = 'account_hidden_posts'
					external = true
				when 'saved'
					feed.type = 'account_saved_posts'
					external = true
				when 'upvoted'
					feed.type = 'account_upvoted_posts'
					external = true
				else
					feed.type = 'multireddit_posts'
					feed.multireddit_name = c
					feed.sort = d if d in SORT_OPTIONS_FEED
		else
			external = true

	#
	# Fill in feed sort and time range values if not specified by user:
	#
	if !feed.sort
		feed.sort = switch
			when feed.search_query then 'relevance'
			when feed.type is 'duplicate_posts' then 'top'
			when feed.type is 'multireddit_posts' then 'hot'
			when feed.type is 'subreddit_posts' then 'hot'
			else 'new'
	if !feed.time_range
		feed.time_range = 'all'

	#
	# Return aggregate route object, removing empty variables:
	#
	route = {
		external
	}
	for object in [feed, post, wiki]
		for k, v of object
			if !v? then delete object[k]
	if feed.type
		route.feed = feed
	if post.id
		route.post = post
	if wiki.page_name and wiki.subreddit_name
		route.wiki = wiki
	return route