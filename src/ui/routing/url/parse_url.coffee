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

	page = 'external'
	subpage = null
	feed = {}
	post = {}
	wiki = {}
	
	#
	# Parse URL query:
	#
	query = new URLSearchParams(decodeURI(url.search))
	feed.after_id = query.get('after')
	if feed.after_id?[2] is '_'
		feed.after_id = feed.after_id[3..]
	feed.filter = query.get('filter')
	flair_search = query.get('f')?.replaceAll('flair_name', 'flair')
	combined_search = [flair_search, query.get('q')].filter((x) -> x).join('+')
	combined_sanitized_search = combined_search.replaceAll(':', '=').replaceAll(' ', '+')
	feed.search = combined_sanitized_search if combined_sanitized_search?.length > 0
	if query.get('sort') in SORT_OPTIONS_FEED or query.get('sort') in SORT_OPTIONS_FEED_SEARCH
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
	# Treat top-level paths as subreddit names unless we know otherwise.
	if path[0]? and path[0] not in RECOGNIZED_TOP_LEVEL_PATH_SEGMENTS
		path.unshift('r')
	[ a, b, c, d, e, f, g ] = path
	switch a
		when undefined
			page = 'directory'
		when 'c', 'collection'
			page = 'collection'
			feed.collection_id = b
		when 'message'
			page = 'user'
			switch b
				when 'compose'
					page = 'external'
				when 'inbox'
					subpage = 'messages'
					feed.filter = 'inbox'
				when 'sent'
					subpage = 'messages'
					feed.filter = 'sent'
				when 'unread'
					subpage = 'messages'
					feed.filter = 'unread'
				else
					subpage = 'replies'
		when 'p', 'post'
			page = 'post'
			post.id = b
			post.focus_comment_id = c
		when 'r', 'subreddit'
			switch b
				when 'all', 'popular'
					page = 'multireddit'
					feed.user_name = 'r'
					feed.multireddit_name = b
					if c is 'about'
						subpage = 'about'
					else if c is 'search'
						subpage = 'search'
					else
						subpage = 'posts'
						feed.sort = c if c in SORT_OPTIONS_FEED
				when 'friends'
					page = 'external'
				when 'mod'
					page = 'external'
				else
					feed.subreddit_name = b
					if c is undefined or c in SORT_OPTIONS_FEED
						page = 'subreddit'
						subpage = 'posts'
						if c in SORT_OPTIONS_FEED
							feed.sort = c
					else switch c
						when 'about'
							page = 'subreddit'
							if d is 'rules'
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
							page = 'external'
						when 'mod'
							page = 'subreddit'
							subpage = 'mod'
						when 'posts'
							page = 'subreddit'
							subpage = 'posts'
						when 'rules'
							page = 'subreddit'
							subpage = 'rules'
						when 'search'
							page = 'subreddit'
							subpage = 'search'
						when 'submit'
							page = 'external'
						when 'w', 'wiki'
							page = 'wiki'
							wiki.subreddit_name = b
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
					switch e
						when 'about'
							subpage = 'about'
						when 'search'
							subpage = 'search'
						else
							subpage = 'posts'
							if feed.multireddit_name is 'subscriptions'
								feed.sort = e if e in SORT_OPTIONS_FEED_FRONTPAGE
							else
								feed.sort = e if e in SORT_OPTIONS_FEED
				when 'gilded'
					page = 'external'
				when 'hidden'
					page = 'external'
				when 'messages'
					subpage = 'messages'
				when 'posts', 'submitted'
					subpage = 'posts'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
				when 'replies'
					subpage = 'replies'
				when 'saved'
					subpage = 'saved'
					switch d
						when 'comments'
							feed.filter = 'comments'
						when 'posts'
							feed.filter = 'posts'
				when 'upvoted'
					page = 'external'
				else
					page = 'multireddit'
					feed.multireddit_name = c
					switch d
						when 'about'
							subpage = 'about'
						when 'search'
							subpage = 'search'
						else
							subpage = 'posts'
							if feed.multireddit_name is 'subscriptions'
								feed.sort = d if d in SORT_OPTIONS_FEED_FRONTPAGE
							else
								feed.sort = d if d in SORT_OPTIONS_FEED
		when 'w', 'wiki'
			page = 'wiki'
			wiki.subreddit_name = 'reddit.com'
			wiki.page_name = [b, c, d, e].filter((x) -> x).join('/') or 'index'

	#
	# Fill in default feed parameters if not specified by user:
	#
	if !feed.filter
		feed.filter = switch
			when subpage is 'mod' then 'posts'
			when subpage is 'posts' and page != 'user' then 'unread'
			when subpage is 'saved' then 'posts'
			else null
	if !feed.sort
		feed.sort = switch
			when subpage is 'search' then 'relevance'
			when page is 'multireddit' then 'hot'
			when page is 'subreddit' then 'hot'
			when page is 'user' then 'top'
			else 'new'
	if !feed.time_range
		feed.time_range = 'all'

	#
	# Return aggregate route object, removing empty variables:
	#
	route = {
		page
	}
	if subpage
		route.subpage = subpage
	for object in [feed, post, wiki]
		for k, v of object
			if !v? then delete object[k]
	if feed.collection_id or feed.subreddit_name or feed.user_name
		route.feed = feed
	if post.id
		route.post = post
	if wiki.page_name and wiki.subreddit_name
		route.wiki = wiki
	
	return route