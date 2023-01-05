COUNTRY_SEO_PREFIXES = [
	'de', 'es', 'fr', 'it', 'pt'
]	
KNOWN_TOP_LEVEL_PATHS = [
	undefined, 'about', 'best', 'c', 'chat', 'collection', 'comments', 'controversial', 'dev', 'domain', 'gallery', 'help', 'hot', 'm', 'mail', 'message', 'messages', 'multi', 'multireddit', 'new', 'p', 'poll', 'post', 'r', 'reddits', 'report', 'rising', 's', 'search', 'submit', 'subreddit', 'subreddits', 'tb', 'top', 'u', 'user', 'w', 'wiki', 'video'
]

SORT_OPTION_TIME_RANGES = [
	'all', 'day', 'hour', 'month', 'week', 'year'
]
LISTING_SORT_OPTIONS = [
	'controversial-all', 'controversial-day', 'controversial-hour', 'controversial-month', 'controversial-week', 'controversial-year', 'hot', 'new', 'top-all', 'top-day', 'top-hour', 'top-month', 'top-week', 'top-year'
]
POPULAR_SORT_OPTIONS = [
	...LISTING_SORT_OPTIONS, 'rising'
]
FRONTPAGE_SORT_OPTIONS = [
	...LISTING_SORT_OPTIONS, 'best', 'rising'
]
SUBREDDIT_SORT_OPTIONS = [
	...LISTING_SORT_OPTIONS, 'rising', 'search-all', 'search-day', 'search-hour', 'search-month', 'search-week', 'search-year'
]
POST_COMMENTS_SORT_OPTIONS = [
	'best', 'controversial', 'new', 'old', 'qa', 'top'
]

ROUTE_INVALID = {
	page_type: 'invalid'
	page_data: null
}
ROUTE_OFFICIALSITE = (from_url) -> {
	page_type: 'official_site'
	page_data: { path: from_url.pathname + from_url.search + from_url.hash }
}

export default (url) ->
	path = url.pathname.split('/').map((x) -> decodeURIComponent(x).replaceAll(' ', '_'))
	query = new URLSearchParams(decodeURI(url.search))
	# Normalize trailing slash if present.
	if path.at(-1) is '' then path.pop()
	# Strip global SEO prefixes.
	if path[1] in COUNTRY_SEO_PREFIXES and path[2] is 'r' and path[3] then path = path[1..]
	# Treat top-level path as subreddit name unless otherwise identified.
	if path[1] not in KNOWN_TOP_LEVEL_PATHS then path = ['', 'r', ...path[1..]]
	# Core routing logic begins from here.
	switch path[1]
		when undefined
			return {
				page_type: 'home'
				page_data: {}
			}
		when 'c', 'collection'
			collection_short_id = path[2]
			return {
				page_type: 'collection'
				page_data: { collection_short_id }
			}
		when 'comments', 'p', 'post', 'tb'
			post_short_id = path[2]
			if not post_short_id then return ROUTE_INVALID
			comments_sort = query.get('sort')
			if comments_sort not in POST_COMMENTS_SORT_OPTIONS then comments_sort = 'best'
			comment_short_id = path[4]
			comment_context = query.get('context')
			return {
				page_type: 'post'
				page_data: { comment_context, comment_short_id, comments_sort, post_short_id }
			}
		when 'm', 'multi', 'multireddit'
			user_name = path[2]
			multireddit_name = path[3]
			if not user_name or not multireddit_name then return ROUTE_INVALID
			posts_sort = path[4] ? query.get('sort')
			if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
				time_range = query.get('t')
				if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
				else posts_sort = posts_sort + '-day'
			else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'top-day'
			search_text = query.get('q')
			return {
				page_type: 'multireddit'
				page_data: { multireddit_name, posts_sort, search_text, user_name }
			}
		when 'mail', 'messages'
			switch path[3]
				when 'message'
					message_short_id = path[4]
					return {
						page_type: 'message'
						page_data: { message_short_id }
					}
				else
					return ROUTE_OFFICIALSITE(url) # TODO
		when 'message'
			message_short_id = path[3]
			return {
				page_type: 'message'
				page_data: { message_short_id }
			}
		when 'r', 'subreddit'
			switch path[3]
				when 'about' then return ROUTE_OFFICIALSITE(url)
				when 'collection'
					collection_short_id = path[4]
					return {
						page_type: 'collection'
						page_data: { collection_short_id }
					}
				when 'comments', 'p', 'post'
					post_short_id = path[4]
					if not post_short_id then return ROUTE_INVALID
					comments_sort = query.get('sort')
					if comments_sort not in POST_COMMENTS_SORT_OPTIONS then comments_sort = 'best'
					comment_short_id = path[6]
					comment_context = query.get('context')
					return {
						page_type: 'post'
						page_data: { comment_context, comment_short_id, comments_sort, post_short_id }
					}
				when 'submit' then return ROUTE_OFFICIALSITE(url)
				when 'w', 'wiki'
					subreddit_name = path[2]
					if not subreddit_name or subreddit_name.length < 2 then return ROUTE_INVALID
					wiki_name = path[4..].join('/') # wiki pages can be nested
					if wiki_name is 'pages'
						return {
							page_type: 'wiki_list'
							page_data: { subreddit_name }
						}
					if not wiki_name then wiki_name = 'index'
					wiki_revision_id = query.get('v')
					return {
						page_type: 'wiki'
						page_data: { subreddit_name, wiki_name, wiki_revision_id }
					}
				else
					subreddit_name = path[2]
					if not subreddit_name or subreddit_name.length < 2 then return ROUTE_INVALID
					switch subreddit_name
						when 'mod' then return ROUTE_OFFICIALSITE(url) # TODO
						else
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-day'
							else if subreddit_name is 'all' and posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'top-day'
							else if subreddit_name is 'popular' and posts_sort not in POPULAR_SORT_OPTIONS then posts_sort = 'top-day'
							else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'top-day'
							search_text = query.get('q')
							switch subreddit_name
								when 'all'
									return {
										page_type: 'multireddit'
										page_data: { multireddit_name: 'all', posts_sort, search_text, user_name: 'r' }
									}
								when 'popular'
									return {
										page_type: 'multireddit'
										page_data: { multireddit_name: 'popular', posts_sort, user_name: 'r' }
									}
								else
									return {
										page_type: 'subreddit'
										page_data: { posts_sort, search_text, subreddit_name }
									}
		when 'reddits', 'subreddits'
			switch path[2]
				when 'mine'
					switch path[3]
						when 'contributor'
							subreddits_filter = 'approved-user'
						when 'moderator'
							subreddits_filter = 'moderator'
						else
							subreddits_filter = 'subscriber'
				when 'approved', 'contributor'
					subreddits_filter = 'approved-user'
				when 'moderated', 'moderating', 'moderator'
					subreddits_filter = 'moderator'
				when 'new'
					subreddits_filter = 'global-new'
				when 'subscribed', 'subscriber', 'subscriptions'
					subreddits_filter = 'subscriber'
				else
					subreddits_filter = 'global-popular'
			return {
				page_type: 'subreddits'
				page_data: { subreddits_filter }
			}
		when 's', 'search' then return ROUTE_OFFICIALSITE(url) # TODO
		when 'u', 'user'
			user_name = path[2]
			if not user_name then return ROUTE_INVALID
			if user_name is 'me' # on official site, redirects to current user
				return ROUTE_OFFICIALSITE(url) # TODO?
			switch path[3]
				when 'comments', 'p', 'post'
					post_short_id = path[4]
					if not post_short_id then return ROUTE_INVALID
					comments_sort = query.get('sort')
					if comments_sort not in POST_COMMENTS_SORT_OPTIONS then comments_sort = 'best'
					comment_short_id = path[6]
					comment_context = query.get('context')
					return {
						page_type: 'post'
						page_data: { comment_context, comment_short_id, comments_sort, post_short_id }
					}
				when 'm', 'multi', 'multireddit'
					multireddit_name = path[4]
					if not multireddit_name then return ROUTE_INVALID
					posts_sort = path[5] ? query.get('sort')
					if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
						time_range = query.get('t')
						if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
						else posts_sort = posts_sort + '-day'
					else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'top-day'
					search_text = query.get('q')
					return {
						page_type: 'multireddit'
						page_data: { multireddit_name, posts_sort, search_text, user_name }
					}
				else
					posts_sort = path[3] ? query.get('sort')
					if posts_sort is 'controversial' or posts_sort is 'top'
						time_range = query.get('t')
						if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
						else posts_sort = posts_sort + '-day'
					else if posts_sort not in LISTING_SORT_OPTIONS then posts_sort = 'top-day'
					return {
						page_type: 'user'
						page_data: { posts_sort, user_name }
					}
		when 'w', 'wiki'
			subreddit_name = path[2]
			if not subreddit_name or subreddit_name.length < 2 then return ROUTE_INVALID
			wiki_name = path[3..].join('/') # wiki pages can be nested
			if wiki_name is 'pages'
				return {
					page_type: 'wiki_list'
					page_data: { subreddit_name }
				}
			if not wiki_name then wiki_name = 'index'
			wiki_revision_id = query.get('v')
			return {
				page_type: 'wiki'
				page_data: { subreddit_name, wiki_name, wiki_revision_id }
			}
	return ROUTE_OFFICIALSITE(url)