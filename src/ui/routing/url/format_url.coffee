export default ({
	after_id
	after_id_type
	collection_id
	feed_filter
	feed_search
	feed_sort
	feed_time_range
	multireddit_name
	post_comments_sort
	post_focus_comment_id
	post_focus_comment_parent_count
	post_id
	subpage
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
		path.push('w')
		for segment in wikipage_name.split('/')
			path.push(segment)
		if wikipage_version
			query.set('v', wikipage_version)
	else if collection_id
		path.push('c')
		path.push(collection_id)
	else if multireddit_name
		path.push('u')
		path.push(user_name)
		path.push(multireddit_name)
	else if user_name
		path.push('u')
		path.push(user_name)
	else if subreddit_name
		path.push(subreddit_name)
	if subpage
		path.push(subpage)
	if feed_filter
		query.set('filter', feed_filter)
	if feed_search
		query.set('q', feed_search)
	if feed_sort
		query.set('sort', feed_sort)
	if feed_time_range
		query.set('t', feed_time_range)
	if after_id
		query.set('after', after_id)
	if after_id_type
		query.set('after_type', after_id_type)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string.toLowerCase()