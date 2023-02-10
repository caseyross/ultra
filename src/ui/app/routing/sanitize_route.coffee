COMMENTS_SORT_OPTIONS_GENERAL =
	['best', 'controversial', 'new', 'old', 'qa', 'top']
POSTS_SORT_OPTIONS_USER =
	['controversial-all', 'controversial-day', 'controversial-hour', 'controversial-month', 'controversial-week', 'controversial-year', 'hot', 'new', 'top-all', 'top-day', 'top-hour', 'top-month', 'top-week', 'top-year']
POSTS_SORT_OPTIONS_ALL_POPULAR =
	[ ...POSTS_SORT_OPTIONS_USER, 'rising' ] # r/popular also has geo sort options, but these are not available via API
POSTS_SORT_OPTIONS_SUBSCRIPTIONS =
	[ ...POSTS_SORT_OPTIONS_ALL_POPULAR, 'best' ]
POSTS_SORT_OPTIONS_GENERAL =
	[ ...POSTS_SORT_OPTIONS_ALL_POPULAR, 'search-all', 'search-day', 'search-hour', 'search-month', 'search-week', 'search-year' ]

INVALID = 
	error: true

export default ({
	format
	collection_short_id
	user_name
	subreddit_name
	multireddit_name
	posts_sort_base
	posts_sort_range
	posts_search_text
	after_post_short_id
	post_short_id
	comment_context
	comment_short_id
	comments_sort
	wikipage_name
	wikipage_revision_id
	listings_type
	url
}) ->
	# Check for missing critical data.
	switch format
		when 'collection'
			if !collection_short_id
				return INVALID
		when 'multireddit'
			if !user_name or !multireddit_name
				return INVALID
		when 'subreddit'
			if !subreddit_name and !post_short_id
				return INVALID
		when 'user'
			if !user_name
				return INVALID
		when 'wiki'
			if !subreddit_name
				return INVALID
	# Reify sort options.
	if comments_sort not in COMMENTS_SORT_OPTIONS_GENERAL
		comments_sort = 'best'
	switch posts_sort_base
		when 'controversial', 'search', 'top'
			posts_sort = posts_sort_base + '-' + (posts_sort_range or 'all')
		else
			posts_sort = posts_sort_base
	switch format
		when 'multireddit'
			if user_name is 'r'
				switch multireddit_name
					when 'all', 'popular'
						if posts_sort not in POSTS_SORT_OPTIONS_ALL_POPULAR
							posts_sort = 'hot'
					when 'subscriptions'
						if posts_sort not in POSTS_SORT_OPTIONS_SUBSCRIPTIONS
							posts_sort = 'best'
			else
				if posts_sort not in POSTS_SORT_OPTIONS_GENERAL
					posts_sort = 'hot'
		when 'subreddit'
			if posts_sort not in POSTS_SORT_OPTIONS_GENERAL
				posts_sort = 'hot'
		when 'user'
			if posts_sort not in POSTS_SORT_OPTIONS_USER
				posts_sort = 'hot'
	if posts_search_text and posts_sort.split('-')[0] is 'search'
		posts_sort = posts_sort + '-' + posts_search_text
	# Save URL path if provided.
	if url
		path = url.pathname + url.search + url.hash
	# Organize response.
	return {
		format
		listing: {
			after_post_short_id
			collection_short_id
			multireddit_name
			posts_sort
			subreddit_name
			user_name
		}
		listings_type
		path
		selection: {
			comment_context
			comment_short_id
			comments_sort
			post_short_id
			wikipage_name
			wikipage_revision_id
		}
	}