export default ({
	collection_id
	feed_filter
	feed_search_sort
	feed_search_text
	feed_sort
	feed_time_range
	multireddit_name
	post_comments_sort
	post_focus_comment_id
	post_focus_comment_parent_count
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
			path.push('post')
		path.push(post_id)
		if collection_id
			query.set('c', collection_id)
		if post_comments_sort
			query.set('comment_sort', post_comments_sort)
		if post_focus_comment_id
			query.set('comment', post_focus_comment_id)
		if post_focus_comment_parent_count
			query.set('context', post_focus_comment_parent_count)
		if multireddit_name
			query.set('m', multireddit_name)
		if user_name
			query.set('u', user_name)
	else if wikipage_name
		path.push(subreddit_name)
		path.push('wiki')
		for segment in wikipage_name.split('/')
			path.push(segment)
		if wikipage_version
			query.set('v', wikipage_version)
	else if collection_id
		path.push('collection')
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
	if feed_filter
		query.set('filter', feed_filter)
	if feed_search_sort
		query.set('search_sort', feed_search_sort)
	if feed_search_text
		query.set('q', feed_search_text)
	if feed_sort
		query.set('sort', feed_sort)
	if feed_time_range
		query.set('t', feed_time_range)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string.toLowerCase()