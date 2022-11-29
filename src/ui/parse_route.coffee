COUNTRY_SEO_PREFIXES = ['de', 'es', 'fr', 'it', 'pt']	
KNOWN_TOP_LEVEL_PATHS = [undefined, 'about', 'best', 'c', 'channel', 'chat', 'collection', 'comments', 'controversial', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'dev', 'gallery', 'help', 'hot', 'm', 'mail', 'message', 'messages', 'multi', 'multireddit', 'new', 'p', 'poll', 'post', 'r', 'report', 'rising', 's', 'search', 'submit', 'subreddit', 'tb', 'top', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'u', 'user', 'w', 'wiki', 'video']
LISTING_SORT_OPTIONS = ['controversial', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'top', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all']
SUBREDDIT_SORT_OPTIONS = [...LISTING_SORT_OPTIONS, 'rising', 'search', 'search-hour', 'search-day', 'search-week', 'search-month', 'search-year', 'search-all']
R_ALL_SORT_OPTIONS = SUBREDDIT_SORT_OPTIONS
R_POPULAR_SORT_OPTIONS = [...LISTING_SORT_OPTIONS, 'rising']
FRONTPAGE_SORT_OPTIONS = [...LISTING_SORT_OPTIONS, 'rising', 'best']
POST_COMMENTS_SORT_OPTIONS = ['best', 'controversial', 'new', 'old', 'qa', 'top']
SORT_OPTION_TIME_RANGES = ['hour', 'day', 'week', 'month', 'year', 'all']

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
			listing_type = switch query.get('lt')
				when 'c' then 'collection_posts'
				when 'm' then 'multireddit_posts'
				when 'r' then 'subreddit_posts'
				when 'u' then 'user_posts'
				else null
			collection_short_id = query.get('li')
			multireddit_name = query.get('ln')
			posts_sort = query.get('ls')
			subreddit_name = query.get('ln')
			user_name = query.get('lu')
			return {
				page_type: 'post'
				page_data: { comment_context, comment_short_id, comments_sort, post_short_id }
				listing_type: listing_type
				listing_data: { collection_short_id, multireddit_name, posts_sort, subreddit_name, user_name }
			}
		when 'm', 'multi', 'multireddit'
			user_name = path[2]
			multireddit_name = path[3]
			if not user_name or not multireddit_name then return ROUTE_INVALID
			posts_sort = path[4] ? query.get('sort')
			if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
				time_range = query.get('t')
				if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
				else posts_sort = posts_sort + '-all'
			else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'hot'
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
					listing_type = switch query.get('lt')
						when 'c' then 'collection_posts'
						when 'm' then 'multireddit_posts'
						when 'r' then 'subreddit_posts'
						when 'u' then 'user_posts'
						else null
					collection_short_id = query.get('li')
					multireddit_name = query.get('ln')
					posts_sort = query.get('ls')
					subreddit_name = query.get('ln') ? path[2]
					user_name = query.get('lu')
					return {
						page_type: 'post'
						page_data: { comment_context, comment_short_id, comments_sort, post_short_id }
						listing_type: listing_type
						listing_data: { collection_short_id, multireddit_name, posts_sort, subreddit_name, user_name }
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
						when 'all'
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-all'
							else if posts_sort not in R_ALL_SORT_OPTIONS then posts_sort = 'hot'
							search_text = query.get('q')
							return {
								page_type: 'multireddit_all'
								page_data: { posts_sort, search_text }
							}
						when 'mod' then return ROUTE_OFFICIALSITE(url) # TODO
						when 'popular'
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-all'
							else if posts_sort not in R_POPULAR_SORT_OPTIONS then posts_sort = 'hot'
							return {
								page_type: 'multireddit_popular'
								page_data: { posts_sort }
							}
						else
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-all'
							else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'hot'
							search_text = query.get('q')
							return {
								page_type: 'subreddit'
								page_data: { posts_sort, search_text, subreddit_name }
							}
		when 's', 'search' then return ROUTE_OFFICIALSITE(url) # TODO
		when 'u', 'user'
			user_name = path[2]
			if not user_name then return ROUTE_INVALID
			if user_name is 'me' # on official site, redirects to current user
				return ROUTE_OFFICIALSITE(url) # TODO?
			switch path[3]
				when 'm', 'multi', 'multireddit'
					multireddit_name = path[4]
					if not multireddit_name then return ROUTE_INVALID
					posts_sort = path[5] ? query.get('sort')
					if posts_sort is 'controversial' or posts_sort is 'search' or posts_sort is 'top'
						time_range = query.get('t')
						if time_range in SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
						else posts_sort = posts_sort + '-all'
					else if posts_sort not in SUBREDDIT_SORT_OPTIONS then posts_sort = 'hot'
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
						else posts_sort = posts_sort + '-all'
					else if posts_sort not in LISTING_SORT_OPTIONS then posts_sort = 'new'
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