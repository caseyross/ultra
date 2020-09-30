export state_from_url = () ->
	options = new URLSearchParams window.location.search
	state =
		list_id: ''
		list_geography: options.get('geo_filter') or 'GLOBAL' # not implemented in API?
		list_page_size: options.get('limit') or 25
		list_predecessor_object_id: options.get('after') or ''
		list_rank_by: options.get('sort') or 'new'
		list_time_period: options.get('t') or 'day'
		object_id: ''
		comroot_id: ''
		comroot_parent_count: options.get('context') or 0
		com_rank_by: 'confidence'
		inspect: off
	[ _, path_prefix, ...path_terms ] = window.location.pathname.split '/'
	switch path_prefix
		when 'r'
			[ subreddit_name, filter, post_id, post_slug, comroot_id ] = path_terms
			if subreddit_name is 'all' or subreddit_name is 'popular'
				state.list_id = 'c/' + subreddit_name
			else
				state.list_id = 'r/' + subreddit_name
			if filter is 'comments'
				state.list_rank_by = 'hot'
				state.object_id = post_id
				state.comroot_id = comroot_id
			else
				state.list_rank_by = filter or 'hot'
		when 'user'
			[ user_name, filter ] = path_terms
			state.list_id = 'u/' + user_name
		when 'message'
			[ filter, message_id ] = path_terms
			state.list_id = 'm/' + filter
		else # treat as front page
			[ rank_by ] = path_terms
			state.list_rank_by = rank_by or 'best'
	return state

url_from_state = (state) ->
	url = '//' + state.list_id
	###
	options = new URLSearchParams()
	options.set('rank_by', state.list_rank_by)
	options.set('time_period', state.list_time_period)
	###
	return url