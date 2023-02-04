import sanitize_route from './sanitize_route.coffee'

COUNTRY_SEO_PREFIXES =
	['de', 'es', 'fr', 'it', 'pt']
RECOGNIZED_TOP_LEVEL_PATHS =
	[undefined, 'about', 'best', 'c', 'chat', 'collection', 'comments', 'controversial', 'dev', 'domain', 'gallery', 'help', 'hot', 'm', 'messages', 'multi', 'multireddit', 'new', 'p', 'poll', 'post', 'r', 'reddits', 'report', 'rising', 's', 'search', 'submit', 'subreddit', 'subreddits', 't', 'tb', 'top', 'u', 'user', 'w', 'wiki', 'video']

export default (url) ->
	path = url.pathname.split('/').map((x) -> decodeURIComponent(x).replaceAll(' ', '_'))
	query = new URLSearchParams(decodeURI(url.search))
	# Normalize trailing slash if present.
	if path.at(-1) is ''
		path.pop()
	# Strip global SEO prefixes.
	if path[1] in COUNTRY_SEO_PREFIXES and path[2] is 'r' and path[3]
		path = path[1..]
	# Treat top-level path as subreddit name unless otherwise identified.
	if path[1] not in RECOGNIZED_TOP_LEVEL_PATHS
		path = ['', 'r', ...path[1..]]
	# Core routing logic begins from here.
	switch path[1]
		when undefined
			return sanitize_route(
				format: 'subscriptions'
			)
		when 'c', 'collection'
			return sanitize_route(
				format: 'collection'
				collection_short_id: path[2]
			)
		when 'comments', 'p', 'post', 'tb'
			return sanitize_route(
				format: 'subreddit'
				subreddit_name: null
				post_short_id: path[2]
				comment_context: query.get('context')
				comment_short_id: path[3] or path[4]
				comments_sort: query.get('sort')
			)
		when 'm', 'multi', 'multireddit'
			return sanitize_route(
				format: 'multireddit'
				user_name: path[2]
				multireddit_name: path[3]
				posts_sort_base: path[4] or query.get('sort')
				posts_sort_range: query.get('t')
				posts_search_text: query.get('q')
				after_post_short_id: query.get('after')
			)
		when 'messages'
			switch path[3]
				when 'message'
					return sanitize_route(
						format: 'messages'
						message_short_id: path[4]
					)
				else
					# TODO
					return sanitize_route(
						format: 'official_site'
						url: url
					)
		when 'r', 'subreddit'
			subreddit_name = path[2]
			switch path[3]
				when undefined
					switch subreddit_name
						when 'all', 'popular', 'subscriptions'
							return sanitize_route(
								format: 'multireddit'
								user_name: 'r'
								multireddit_name: subreddit_name
								posts_sort_base: path[3] or query.get('sort')
								posts_sort_range: query.get('t')
								posts_search_text: query.get('q')
								after_post_short_id: query.get('after')
							)
						else
							return sanitize_route(
								format: 'subreddit'
								subreddit_name: subreddit_name
								posts_sort_base: path[3] or query.get('sort')
								posts_sort_range: query.get('t')
								posts_search_text: query.get('q')
								after_post_short_id: query.get('after')
							)
				when 'about'
					# TODO?
					return sanitize_route(
						format: 'official_site'
						url: url
					)
				when 'collection'
					return sanitize_route(
						format: 'collection'
						collection_short_id: path[4]
					)
				when 'comments', 'p', 'post'
					return sanitize_route(
						format: 'subreddit'
						subreddit_name: path[2]
						posts_sort_base: query.get('sort')
						posts_sort_range: query.get('t')
						posts_search_text: query.get('q')
						after_post_short_id: query.get('after')
						post_short_id: path[4]
						comment_context: query.get('context')
						comment_short_id: path[6]
						comments_sort: query.get('sort')
					)
				when 'submit'
					return sanitize_route(
						format: 'official_site'
						url: url
					)
				when 'w', 'wiki'
					return sanitize_route(
						format: 'wiki'
						subreddit_name: path[2]
						wikipage_name: path[4..]?.join('/') or 'index' # wiki pages can be nested
						wikipage_revision_id: query.get('v')
					)
				else
					return sanitize_route(
						format: 'subreddit'
						subreddit_name: path[2]
						posts_sort_base: query.get('sort')
						posts_sort_range: query.get('t')
						posts_search_text: query.get('q')
						after_post_short_id: query.get('after')
						post_short_id: path[3]
						comment_context: query.get('context')
						comment_short_id: path[4]
						comments_sort: query.get('sort')
					)
		when 'reddits', 'subreddits'
			subreddits_filter = switch path[2]
				when 'mine'
					switch path[3]
						when 'contributor' then 'approved-user'
						when 'moderator' then 'moderator'
						else 'subscriber'
				when 'approved', 'contributor' then 'approved-user'
				when 'moderated', 'moderating', 'moderator' then 'moderator'
				when 'new' then 'global-new'
				when 'subscribed', 'subscriber', 'subscriptions' then 'subscriber'
				else 'global-popular'
			return sanitize_route(
				format: 'subreddit_list'
				subreddits_filter: subreddits_filter
			)
		when 's', 'search'
			# TODO
			return sanitize_route(
				format: 'official_site'
				url: url
			)
		when 'u', 'user'
			user_name = path[2]
			if user_name is 'me'
				# Redirects to profile of current user on the official site.
				# TODO? 
				return sanitize_route(
					format: 'account'
				)
			switch path[3]
				when 'comments', 'p', 'post'
					return sanitize_route(
						format: 'user'
						user_name: user_name
						posts_sort_base: path[3] or query.get('sort')
						posts_sort_range: query.get('t')
						posts_search_text: query.get('q')
						after_post_short_id: query.get('after')
						post_short_id: path[4]
						comment_context: query.get('context')
						comment_short_id: path[6]
						comments_sort: query.get('sort')
					)
				when 'm', 'multi', 'multireddit'
					return sanitize_route(
						format: 'multireddit'
						user_name: user_name
						multireddit_name: path[4]
						posts_sort_base: path[5] or query.get('sort')
						posts_sort_range: query.get('t')
						posts_search_text: query.get('q')
						after_post_short_id: query.get('after')
					)
				else
					return sanitize_route(
						format: 'user'
						user_name: user_name
						posts_sort_base: path[3] or query.get('sort')
						posts_sort_range: query.get('t')
						posts_search_text: query.get('q')
						after_post_short_id: query.get('after')
					)
		when 'w', 'wiki'
			return sanitize_route(
				format: 'wiki'
				subreddit_name: path[2]
				wikipage_name: path[3..]?.join('/') or 'index' # wiki pages can be nested
				wikipage_revision_id: query.get('v')
			)
	return sanitize_route(
		format: 'official_site'
		url: url
	)