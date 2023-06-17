export default ({
	collection_id
	feed_search
	feed_sort
	feed_time_range
	multireddit_name
	page_type
	post_comments_sort
	post_focus_comment_parent_count
	post_focus_comment_id
	post_id
	subreddit_name
	user_name
	wikipage_name
	wikipage_version
}) ->
	path = ['']
	query = new URLSearchParams
	if post_id
		if subreddit_name
			path.push(subreddit_name)
		else
			path.push('p')
		path.push(post_id)
		if post_comments_sort
			query.set('comment_sort', post_comments_sort)
		if post_focus_comment_id
			query.set('comment', post_focus_comment_id)
		if post_focus_comment_parent_count
			query.set('context', post_focus_comment_parent_count)
	else if wikipage_name
		path.push(subreddit_name)
		for segment in wikipage_name.split('/')
			path.push(segment)
		if wikipage_version
			query.set('v', wikipage_version)
	else if page_type
		switch page_type
			when 'collection'
				path.push('c')
				path.push(collection_id)
			when 'multireddit'
				path.push('u')
				path.push(user_name)
				path.push(multireddit_name)
			when 'subreddit'
				path.push(subreddit_name)
			when 'user'
				path.push('u')
				path.push(user_name)
		if feed_search
			query.set('q', feed_search)
		if feed_sort
			query.set('sort', feed_sort)
		if feed_time_range
			query.set('t', feed_time_range)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string.toLowerCase()