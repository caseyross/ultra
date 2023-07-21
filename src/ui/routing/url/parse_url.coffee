import api from '../../../api/index.js'

FEED_PAGE_SIZE = 10
GEO_SEO_PREFIXES =
	['de', 'es', 'fr', 'it', 'pt']
POST_COMMENTS_INITIAL_SIZE = 25
RECOGNIZED_PRIMARY_PATH_SEGMENTS =
	['api', 'c', 'chat', 'collection', 'dev', 'domain', 'gallery', 'link', 'live', 'login', 'message', 'p', 'poll', 'post', 'prefs', 'premium', 'r', 'reddits', 'register', 'report', 'rules', 'search', 'submit', 'subreddit', 'subreddits', 't', 'tb', 'u', 'user', 'video', 'w', 'wiki'] # front page sort options handled separately
RECOGNIZED_SUBREDDIT_PATH_SEGMENTS =
	['about', 'c', 'collection', 'comments', 'duplicates', 'mod', 'p', 'post', 'posts', 'rules', 'search', 'submit', 'w', 'wiki']
RECOGNIZED_USER_PATH_SEGMENTS =
	['comments', 'downvoted', 'gilded', 'hidden', 'm', 'messages', 'overview', 'posts', 'saved', 'submitted', 'upvoted']
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
	
	preload = []
	
	#
	# Parse URL query:
	#
	query = new URLSearchParams(decodeURI(url.search))
	# Feed parameters:
	feed.after_id = query.get('after')
	if feed.after_id?[2] is '_'
		feed.after_id = feed.after_id.slice(3)
	feed.after_id_type = query.get('after_type')
	feed.filter = query.get('filter')
	feed_flair_search = query.get('f')?.replaceAll('flair_name', 'flair')
	feed_text_search = query.get('q')
	feed_combined_search = [feed_flair_search, feed_text_search].filter((x) -> x).join('+').replaceAll(':', '=').replaceAll(' ', '+')
	if feed_combined_search.length > 0
		feed.search = feed_combined_search
	if query.get('sort') in SORT_OPTIONS_FEED or query.get('sort') in SORT_OPTIONS_FEED_SEARCH
		feed.sort = query.get('sort')
	feed.time_range =
		if query.get('t') in TIMERANGE_OPTIONS
			query.get('t')
		else
			'all'
	# Post parameters:
	if query.get('comment_sort') in SORT_OPTIONS_POST_COMMENTS
		post.comments_sort = query.get('comment_sort')
	post.focus_comment_id = query.get('comment')
	post.focus_comment_parent_count = query.get('context')
	# Wiki parameters:
	wiki.page_version = query.get('v')
	
	#
	# Normalize and parse URL path:
	#
	path = url.pathname.split('/').map((x) -> decodeURIComponent(x).replaceAll(' ', '_'))
	# Strip empty leading/trailing segments.
	if path[0] is ''
		path.shift()
	if path.at(-1) is ''
		path.pop()
	# Strip global SEO prefixes (but keep r/de).
	if path[0] in GEO_SEO_PREFIXES and path[1] is 'r' and path[2]?
		path.shift()
	# Treat top-level paths as subreddit names unless we know otherwise.
	if path[0]? and path[0] not in RECOGNIZED_PRIMARY_PATH_SEGMENTS
		path.splice(0, 0, 'r')
	# Convert r/all and r/popular to normal multireddit format.
	if path[0] is 'r' and path[1] in ['all', 'popular']
		path.splice(0, 0, 'u')
	# Normalize subreddit post paths.
	if path[0] is 'r' and path[2]? and path[2] not in RECOGNIZED_SUBREDDIT_PATH_SEGMENTS and path[2] not in SORT_OPTIONS_FEED
		path.splice(2, 0, 'p')
		if path[4]?
			path.splice(4, 0, '_')
	# Normalize "user subreddit" post paths.
	if path[0] in ['u', 'user'] and path[2] is 'comments' and path[3]?
		path.splice(0, 2, 'r', 'u_' + path[1])
	# For user paths, treat third-level paths as multireddit names unless we know otherwise.
	if path[0] in ['u', 'user'] and path[2]? and path[2] not in RECOGNIZED_USER_PATH_SEGMENTS
		path.splice(2, 0, 'm')
	# Top-level wiki paths redirect to the r/reddit.com wiki.
	if path[0] in ['w', 'wiki']
		path.splice(0, 0, 'r', 'reddit.com')
	[ a, b, c, d, e, f, g ] = path
	switch a
		when undefined
			page = 'directory'
			if api.getUser()
				feed.base_page_id = api.ID('account_subreddits_subscribed', 100)
			else
				feed.base_page_id = api.ID('subreddits_popular', 25)
		when 'c', 'collection'
			page = 'collection'
			feed.collection_id = b
			if c is 'about'
				subpage = 'about'
			feed.base_page_id = api.ID('collection', feed.collection_id)
		when 'message'
			page = 'user'
			subpage = 'messages'
			feed.user_name = api.getUser()
			switch b
				when 'compose'
					page = 'external'
				when 'inbox'
					feed.filter = 'inbox'
				when 'sent'
					feed.filter = 'sent'
				when 'unread'
					feed.filter = 'unread'
			if !feed.filter
				feed.filter = 'unread'
			feed.base_page_id = api.ID('account_messages', feed.filter, FEED_PAGE_SIZE)
		when 'p', 'post'
			page = 'post'
			post.id = b
			if c?
				post.focus_comment_id = c
			if !post.focus_comment_id?
				delete post.focus_comment_parent_count
			preload.push(api.ID('post', post.id, post.comments_sort or 'confidence', POST_COMMENTS_INITIAL_SIZE, post.focus_comment_id, post.focus_comment_parent_count))
		when 'r', 'subreddit'
			if b in ['friends', 'mod']
				page = 'external'
			else
				feed.subreddit_name = b
				preload.push(api.ID('subreddit', feed.subreddit_name))
				if c is undefined or c in SORT_OPTIONS_FEED
					page = 'subreddit'
					subpage = 'posts'
					feed.sort = c if c in SORT_OPTIONS_FEED
					if !feed.filter
						feed.filter = 'unread'
					if !feed.sort
						feed.sort = 'hot'
					feed.base_page_id = api.ID('subreddit_posts', feed.subreddit_name, feed.time_range, feed.sort, FEED_PAGE_SIZE)
				else switch c
					when 'about'
						page = 'subreddit'
						if d is 'rules'
							subpage = 'rules'
							preload.push(api.ID('subreddit_rules', feed.subreddit_name))
						else
							subpage = 'about'
					when 'c', 'collection'
						page = 'collection'
						feed.collection_id = d
						if e is 'about'
							subpage = 'about'
						feed.base_page_id = api.ID('collection', feed.collection_id)
					when 'comments', 'p', 'post'
						page = 'post'
						post.id = d
						if f?
							post.focus_comment_id = f
						if !post.focus_comment_id?
							delete post.focus_comment_parent_count
						# handle overloaded `sort` param on legacy post page
						delete feed.sort
						if query.get('sort') in SORT_OPTIONS_POST_COMMENTS
							post.comments_sort = query.get('sort')
						# best guess preload ID; we prefer to use `post.suggested_sort` but that's unknown at this stage
						preload.push(api.ID('post', post.id, post.comments_sort or 'confidence', POST_COMMENTS_INITIAL_SIZE, post.focus_comment_id, post.focus_comment_parent_count))
					when 'mod'
						page = 'subreddit'
						subpage = 'mod'
						if !feed.filter
							feed.filter = 'posts'
						feed.base_page_id = api.ID("subreddit_modqueue_#{filter}", feed.subreddit_name, FEED_PAGE_SIZE)
					when 'posts'
						page = 'subreddit'
						subpage = 'posts'
						if !feed.filter
							feed.filter = 'unread'
						if !feed.sort
							feed.sort = 'hot'
						feed.base_page_id = api.ID('subreddit_posts', feed.subreddit_name, feed.time_range, feed.sort, FEED_PAGE_SIZE)
					when 'rules'
						page = 'subreddit'
						subpage = 'rules'
						preload.push(api.ID('subreddit_rules', feed.subreddit_name))
					when 'search'
						page = 'subreddit'
						subpage = 'search'
						if !feed.sort
							feed.sort = 'relevance'
						if feed.search
							feed.base_page_id = api.ID('search_posts', "subreddit=#{feed.subreddit_name}+#{feed.search}", 'all', feed.sort, FEED_PAGE_SIZE)
					when 'w', 'wiki'
						page = 'wiki'
						wiki.subreddit_name = b
						wiki.page_name = [d, e, f, g].filter((x) -> x).join('/') or 'index'
						if wiki.page_name == 'pages'
							preload.push(api.ID('wiki_pages', wiki.subreddit_name))
						else
							preload.push(api.ID('wiki', wiki.subreddit_name, wiki.page_name, wiki.page_version))
		when 'u', 'user'
			page = 'user'
			feed.user_name = b
			preload.push(api.ID('user', feed.user_name))
			switch c
				when undefined, 'comments'
					subpage = 'comments'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
					if !feed.sort
						feed.sort = 'top'
					feed.base_page_id = api.ID('user_comments', feed.user_name, feed.time_range, feed.sort, FEED_PAGE_SIZE)
				when 'm'
					page = 'multireddit'
					feed.multireddit_name = d
					preload.push(api.ID('multireddit', feed.user_name, feed.multireddit_name))
					switch e
						when 'about'
							subpage = 'about'
						when 'search'
							subpage = 'search'
							if !feed.sort
								feed.sort = 'relevance'
							if feed.search
								feed.base_page_id = api.ID('search_posts', "multireddit=#{feed.user_name}-#{feed.multireddit_name}+#{feed.search}", 'all', feed.sort, FEED_PAGE_SIZE)
						else
							subpage = 'posts'
							if feed.user_name is 'r' and feed.multireddit_name is 'subscribed'
								feed.sort = e if e in SORT_OPTIONS_FEED_FRONTPAGE
								if !feed.sort
									feed.sort = 'best'
							else
								feed.sort = e if e in SORT_OPTIONS_FEED
								if !feed.sort
									feed.sort = 'hot'
							if !feed.filter
								feed.filter = 'unread'
							feed.base_page_id = api.ID('multireddit_posts', feed.user_name, feed.multireddit_name, feed.time_range, feed.sort, FEED_PAGE_SIZE)
				when 'messages'
					subpage = 'messages'
					if !feed.filter
						feed.filter = 'unread'
					feed.base_page_id = api.ID('account_messages', feed.filter, FEED_PAGE_SIZE)
				when 'posts', 'submitted'
					subpage = 'posts'
					feed.sort = d if d in SORT_OPTIONS_FEED_USER
					if !feed.sort
						feed.sort = 'top'
					feed.base_page_id = api.ID('user_posts', feed.user_name, feed.time_range, feed.sort, FEED_PAGE_SIZE)
				when 'saved'
					subpage = 'saved'
					switch d
						when 'comments'
							feed.filter = 'comments'
						when 'posts'
							feed.filter = 'posts'
					if !feed.filter
						feed.filter = 'posts'
					feed.base_page_id = api.ID("account_saved_#{feed.filter}", feed.user_name, FEED_PAGE_SIZE)

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
	if feed.base_page_id
		preload.unshift(feed.base_page_id)
	if preload.length > 0
		route.preload = preload
	if page is 'external'
		delete route.preload
	
	return route