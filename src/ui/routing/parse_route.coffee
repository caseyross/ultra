KNOWN_TOP_LEVEL_PATHS = [undefined, 'about', 'best', 'channel', 'chat', 'comments', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'dev', 'gallery', 'hot', 'm', 'mail', 'message', 'messages', 'multi', 'multireddit', 'new', 'p', 'poll', 'post', 'r', 'report', 'rising', 's', 'search', 'submit', 'subreddit', 'tb', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'u', 'user', 'w', 'wiki', 'video']

COUNTRY_SEO_PREFIXES = ['de', 'es', 'fr', 'it', 'pt']

LISTING_SORT_OPTIONS = [
	'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all', 'hot', 'new', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all'
]

POST_LISTING_SORT_OPTIONS = [...LISTING_SORT_OPTIONS, 'rising']

FRONTPAGE_POST_LISTING_SORT_OPTIONS = [...POST_LISTING_SORT_OPTIONS, 'best']

POST_COMMENT_LISTING_SORT_OPTIONS = ['best', 'controversial', 'new', 'old', 'qa', 'top']

LISTING_SORT_OPTION_TIME_RANGES = ['hour', 'day', 'week', 'month', 'year', 'all']

INVALID = {
	path: 'invalid'
	data: null
}
OFFICIAL_SITE = (path) -> {
	path: 'official_site'
	data:
		path: path
}
TODO = {
	path: 'todo'
	data: null
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
	if path[1] is undefined or path[1] in POST_LISTING_SORT_OPTIONS
		posts_sort = path[1] ? query.get('sort')
		if posts_sort is 'controversial' or posts_sort is 'top'
			time_range = query.get('t')
			if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
			else posts_sort = posts_sort + '-week'
		else if posts_sort not in FRONTPAGE_POST_LISTING_SORT_OPTIONS then posts_sort = 'best'
		return {
			path: 'home'
			data: { posts_sort }
		}
	switch path[1]
		when 'comments', 'p', 'post', 'tb'
			post_short_id = path[2]
			if not post_short_id then return INVALID
			comments_sort = query.get('sort')
			if comments_sort not in POST_COMMENT_LISTING_SORT_OPTIONS then comments_sort = 'best'
			comment_short_id = path[4]
			comment_context = query.get('context')
			return {
				path: 'post'
				data: { comment_context, comment_short_id, comments_sort, post_short_id }
			}
		when 'm', 'multi', 'multireddit'
			user_name = path[2]
			multireddit_name = path[3]
			if not user_name or not multireddit_name then return INVALID
			posts_sort = path[4] ? query.get('sort')
			if posts_sort is 'controversial' or posts_sort is 'top'
				time_range = query.get('t')
				if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
				else posts_sort = posts_sort + '-month'
			else if posts_sort not in POST_LISTING_SORT_OPTIONS then posts_sort = 'hot'
			return {
				path: 'multireddit'
				data: { multireddit_name, posts_sort, user_name }
			}
		when 'mail', 'message', 'messages'
			return {
				path: 'inbox'
				data: null
			}
		when 'r', 'subreddit'
			switch path[3]
				when 'about' then return OFFICIAL_SITE("/r/#{path[2]}/about")
				when 'comments'
					post_short_id = path[4]
					if not post_short_id then return INVALID
					comments_sort = query.get('sort')
					if comments_sort not in POST_COMMENT_LISTING_SORT_OPTIONS then comments_sort = 'best'
					comment_short_id = path[6]
					comment_context = query.get('context')
					return {
						path: 'post'
						data: { comment_context, comment_short_id, comments_sort, post_short_id }
					}
				when 's', 'search' then return TODO
				when 'submit' then return OFFICIAL_SITE("/r/#{path[2]}/submit")
				when 'w', 'wiki'
					subreddit_name = path[2]
					if not subreddit_name or subreddit_name.length < 2 then return INVALID
					page_name = path[4..].join('/') # wiki pages can be nested
					if page_name is 'pages'
						return {
							path: 'wiki_list'
							data: { subreddit_name }
						}
					if not page_name then page_name = 'index'
					revision_id = query.get('v')
					return {
						path: 'wiki'
						data: { page_name, revision_id, subreddit_name }
					}
				else
					subreddit_name = path[2]
					if not subreddit_name or subreddit_name.length < 2 then return INVALID
					switch subreddit_name
						when 'all'
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-week'
							else if posts_sort not in POST_LISTING_SORT_OPTIONS then posts_sort = 'hot'
							return {
								path: 'all'
								data: { posts_sort }
							}
						when 'mod' then return TODO
						when 'popular'
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-week'
							else if posts_sort not in POST_LISTING_SORT_OPTIONS then posts_sort = 'hot'
							geo_filter = query.get('geo_filter')
							if not geo_filter then geo_filter = 'GLOBAL'
							return {
								path: 'popular'
								data: { geo_filter, posts_sort }
							}
						else
							posts_sort = path[3] ? query.get('sort')
							if posts_sort is 'controversial' or posts_sort is 'top'
								time_range = query.get('t')
								if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
								else posts_sort = posts_sort + '-month'
							else if posts_sort not in POST_LISTING_SORT_OPTIONS then posts_sort = 'hot'
							return {
								path: 'subreddit'
								data: { posts_sort, subreddit_name }
							}
		when 's', 'search' then return TODO
		when 'u', 'user'
			user_name = path[2]
			if not user_name then return INVALID
			switch path[3]
				when 'comments' then items_filter = 'comments'
				when 'm', 'multi', 'multireddit'
					multireddit_name = path[4]
					if not multireddit_name then return INVALID
					posts_sort = path[5] ? query.get('sort')
					if posts_sort is 'controversial' or posts_sort is 'top'
						time_range = query.get('t')
						if time_range in LISTING_SORT_OPTION_TIME_RANGES then posts_sort = posts_sort + '-' + time_range
						else posts_sort = posts_sort + '-month'
					else if posts_sort not in POST_LISTING_SORT_OPTIONS then posts_sort = 'hot'
					return {
						path: 'multireddit'
						data: { multireddit_name, posts_sort, user_name }
					}
				else items_filter = 'posts'
			items_sort = query.get('sort')
			if items_sort is 'controversial' or items_sort is 'top'
				time_range = query.get('t')
				if time_range in LISTING_SORT_OPTION_TIME_RANGES then items_sort = items_sort + '-' + time_range
				else items_sort = items_sort + '-all'
			else if items_sort not in LISTING_SORT_OPTIONS then items_sort = 'new'
			return {
				path: 'user'
				data: { items_filter, items_sort, user_name }
			}
		when 'w', 'wiki'
			subreddit_name = path[2]
			if not subreddit_name or subreddit_name.length < 2 then return INVALID
			page_name = path[3..].join('/') # wiki pages can be nested
			if page_name is 'pages'
				return {
					path: 'wiki_list'
					data: { subreddit_name }
				}
			if not page_name then page_name = 'index'
			revision_id = query.get('v')
			return {
				path: 'wiki'
				data: { page_name, revision_id, subreddit_name }
			}
	return OFFICIAL_SITE(url.pathname + url.search + url.hash)