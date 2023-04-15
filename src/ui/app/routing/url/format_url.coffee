export default ({
	collection_short_id
	feed_search_query
	feed_sort
	feed_time_range
	feed_type
	multireddit_name
	post_comments_sort
	post_focus_comment_parent_count
	post_focus_comment_short_id
	post_short_id
	subreddit_name
	user_name
	wikipage_name
	wikipage_version
}) ->
	path = ['']
	query = new URLSearchParams
	if post_short_id
		if subreddit_name
			path.push(subreddit_name)
		else
			path.push('p')
		path.push(post_short_id)
		if post_comments_sort
			query.set('comment_sort', post_comments_sort)
		if post_focus_comment_short_id
			query.set('comment', post_focus_comment_short_id)
		if post_focus_comment_parent_count
			query.set('context', post_focus_comment_parent_count)
	else if wikipage_name
		path.push(subreddit_name)
		for segment in wikipage_name.split('/')
			path.push(segment)
		if wikipage_version
			query.set('v', wikipage_version)
	else if feed_type
		switch feed_type
			when 'collection'
				path.push('c')
				path.push(collection_short_id)
			when 'multireddit'
				path.push('m')
				path.push(user_name)
				path.push(multireddit_name)
			when 'subreddit'
				path.push(subreddit_name)
			when 'user'
				path.push('u')
				path.push(user_name)
		if feed_search_query
			query.set('q', feed_search_query)
		if feed_sort
			query.set('sort', feed_sort)
		if feed_time_range
			query.set('t', feed_time_range)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string.toLowerCase()