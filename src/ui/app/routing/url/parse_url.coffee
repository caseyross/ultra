GEO_SEO_PREFIXES =
	['de', 'es', 'fr', 'it', 'pt']
RECOGNIZED_TOP_LEVEL_PATH_SEGMENTS =
	['api', 'c', 'chat', 'collection', 'dev', 'domain', 'gallery', 'link', 'm', 'message', 'multi', 'p', 'poll', 'post', 'prefs', 'r', 'reddits', 'report', 'search', 'submit', 'subreddit', 'subreddits', 't', 'tb', 'u', 'user', 'video', 'w', 'wiki'] # front page sort options handled separately
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
	vars = new Map()
	
	query = new URLSearchParams(decodeURI(url.search))
	feed_flair_search_query = query.get('f')?.replaceAll('flair_name', 'flair')
	feed_combined_search_query = [feed_flair_search_query, query.get('q')].filter((x) -> x).join('+')
	feed_combined_sanitized_search_query = feed_combined_search_query.replaceAll(':', '=').replaceAll(' ', '+')
	vars.set('feed_search_query', feed_combined_sanitized_search_query)
	if query.get('sort') in SORT_OPTIONS_FEED_SEARCH and query.get('q')
		vars.set('feed_sort', query.get('sort'))
	else if query.get('sort') in SORT_OPTIONS_FEED
		vars.set('feed_sort', query.get('sort'))
	if query.get('t') in TIMERANGE_OPTIONS
		vars.set('feed_time_range', query.get('t'))
	if query.get('comment_sort') in SORT_OPTIONS_POST_COMMENTS
		vars.set('post_comments_sort', query.get('comment_sort'))
	vars.set('post_focus_comment_parent_count', query.get('context'))
	vars.set('post_focus_comment_short_id', query.get('comment'))
	vars.set('wikipage_version', query.get('v'))
	
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
	if path[0] in [undefined, ...SORT_OPTIONS_FEED_FRONTPAGE]
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
			vars.set('collection_short_id', b)
			vars.set('post_short_id', c)
		when 'm', 'multi'
			vars.set('user_name', b)
			vars.set('multireddit_name', c)
			switch
				when d in SORT_OPTIONS_FEED
					vars.set('feed_sort', d)
				else
					vars.set('post_short_id', d)
		when 'r', 'subreddit'
			vars.set('subreddit_name', b)
			if c in SORT_OPTIONS_FEED
				vars.set('feed_sort', c)
			else switch c
				when 'c', 'collection'
					vars.set('collection_short_id', d)
				when 'comments', 'p', 'post'
					vars.set('post_short_id', d)
					vars.set('post_focus_comment_short_id', f)
					# handle overloaded "sort" on post page
					vars.set('feed_sort', null)
					if query.get('sort') in SORT_OPTIONS_POST_COMMENTS
						vars.set('post_comments_sort', query.get('sort'))
				when 'duplicates'
					vars.set('post_short_id', d)
				when 'search'
					null
				when 'submit'
					null
				when 'w', 'wiki'
					vars.set('wikipage_name', [d, e, f, g].filter((x) -> x).join('/') or 'index')
				else
					vars.set('post_short_id', c)
		when 'p', 'post'
			vars.set('post_short_id', b)
		when 'u', 'user'
			vars.set('user_name', b)
			switch c
				when 'comments', 'overview', 'submitted'
					if d in SORT_OPTIONS_FEED_USER
						vars.set('feed_sort', d)
				when 'm'
					vars.set('multireddit_name', d)
					if e in SORT_OPTIONS_FEED
						vars.set('feed_sort', e)
				else
					vars.set('post_short_id', c)
					
	vars.forEach((value, key) ->
		if !value
			vars.delete(key)
	)
	return vars