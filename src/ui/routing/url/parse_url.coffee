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

	page = 'none'
	subpage = null
	feed = {}
	post = {}
	wiki = {}
	
	#
	# Parse URL query:
	#
	query = new URLSearchParams(decodeURI(url.search))
	flair_search = query.get('f')?.replaceAll('flair_name', 'flair')
	combined_search = [flair_search, query.get('q')].filter((x) -> x).join('+')
	combined_sanitized_search = combined_search.replaceAll(':', '=').replaceAll(' ', '+')
	feed.search = combined_sanitized_search if combined_sanitized_search?.length > 0
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
		when undefined
			page = 'directory'
		when 'c', 'collection'
			page = 'collection'
			feed.collection_id = b
		when 'message'
			page = 'messages'
			switch b
				when 'compose'
					page = 'none'
				when 'inbox'
					feed.sort = 'inbox'
				when 'sent'
					feed.sort = 'sent'
				else
					feed.sort = 'unread'
		when 'p', 'post'
			page = 'post'
			post.id = b
			post.focus_comment_id = c
		when 'r', 'subreddit'
			feed.subreddit_name = b
			if c in [undefined, 'search'] or c in SORT_OPTIONS_FEED
				page = 'subreddit'
				if c in SORT_OPTIONS_FEED
					feed.sort = c
			else switch c
				when 'about'
					page = 'subreddit'
					switch d
						when 'rules'
							subpage = 'rules'
						else
							subpage = 'about'
				when 'c', 'collection'
					page = 'collection'
					feed.collection_id = d
				when 'comments', 'p', 'post'
					page = 'post'
					post.id = d
					post.focus_comment_id = f
					# handle overloaded `sort` param on legacy post page
					delete feed.sort
					post.comments_sort = query.get('sort') if query.get('sort') in SORT_OPTIONS_POST_COMMENTS
				when 'duplicates'
					page = 'duplicates'
					feed.duplicate_post_id = d
				when 'submit'
					page = 'none'
				when 'w', 'wiki'
					wiki.subreddit_name = b
					if d is 'pages'
						page = 'none'
					else
						page = 'wiki'
						wiki.page_name = [d, e, f, g].filter((x) -> x).join('/') or 'index'
				else
					page = 'post'
					post.id = c
		when 'u', 'user'
			page = 'user'
			feed.user_name = b
			switch c
				when undefined, 'comments'
					subpage = 'comments'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
				when 'downvoted'
					page = 'external'
				when 'm'
					page = 'multireddit'
					feed.multireddit_name = d
					feed.sort = e if e in SORT_OPTIONS_FEED
				when 'gilded'
					page = 'external'
				when 'hidden'
					page = 'external'
				when 'posts', 'submitted'
					subpage = 'posts'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
				when 'saved'
					switch d
						when 'comments'
							subpage = 'saved-comments'
						else
							subpage = 'saved-posts'
				when 'upvoted'
					page = 'external'
				else
					page = 'multireddit'
					feed.multireddit_name = c
					feed.sort = d if d in SORT_OPTIONS_FEED

	#
	# Fill in feed sort and time range values if not specified by user:
	#
	if !feed.sort
		feed.sort = switch
			when feed.search then 'relevance'
			when page is 'duplicates' then 'top'
			when page is 'multireddit' then 'hot'
			when page is 'subreddit' then 'hot'
			else 'new'
	if !feed.time_range
		feed.time_range = 'all'

	#
	# Return aggregate route object, removing empty variables:
	#
	route = {
		page
	}
	for object in [feed, post, wiki]
		for k, v of object
			if !v? then delete object[k]
	if feed.collection_id or feed.duplicate_post_id or feed.subreddit_name or feed.user_name
		route.feed = feed
	if post.id
		route.post = post
	if wiki.page_name and wiki.subreddit_name
		route.wiki = wiki
	
	return route