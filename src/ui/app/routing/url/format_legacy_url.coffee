export default ({
	collection_short_id
	feed_search_query
	feed_sort
	feed_time_range
	feed_type
	multireddit_name
	page_type
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
	switch page_type
		when 'post', 'wiki'
			switch page_type
				when 'post'
					path.push('r')
					path.push(subreddit_name)
					path.push('comments')
					path.push(post_short_id)
					if post_comments_sort
						query.set('sort', post_comments_sort)
					if post_focus_comment_short_id
						path.push('_')
						path.push(post_focus_comment_short_id)
					if post_focus_comment_parent_count
						query.set('context', post_focus_comment_parent_count)
				when 'wiki'
					path.push('r')
					path.push(subreddit_name)
					path.push('wiki')
					path.push(wikipage_name)
					if wikipage_version
						query.set('v', wikipage_version)
		else
			switch page_type
				when 'collection'
					path.push('collection')
					path.push(collection_short_id)
				when 'multireddit'
					path.push('user')
					path.push(user_name)
					path.push('m')
					path.push(multireddit_name)
					if feed_sort
						path.push(feed_sort)
				when 'subreddit'
					path.push('r')
					path.push(subreddit_name)
					if feed_sort
						path.push(feed_sort)
				when 'user'
					path.push('user')
					path.push(user_name)
			if feed_search_query
				query.set('q', feed_search_query)
			if feed_sort
				query.set('sort', feed_sort) # note: ignored for subs & multis
			if feed_time_range
				query.set('t', feed_time_range)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string