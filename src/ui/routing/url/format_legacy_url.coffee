export default ({
	after_id
	after_id_type
	collection_id
	feed_search
	feed_sort
	feed_time_range
	multireddit_name
	page_type
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
	switch page_type
		when 'post', 'wiki'
			switch page_type
				when 'post'
					path.push('r')
					path.push(subreddit_name)
					path.push('comments')
					path.push(post_id)
					if post_comments_sort
						query.set('sort', post_comments_sort)
					if post_focus_comment_id
						path.push('_')
						path.push(post_focus_comment_id)
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
					path.push(collection_id)
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
			if feed_search
				query.set('q', feed_search)
			if feed_sort
				query.set('sort', feed_sort) # note: ignored for subs & multis
			if feed_time_range
				query.set('t', feed_time_range)
			if after_id and after_id_type
				after_fullname = switch after_id_type
					when 'comment' then 't1_' + after_id
					when 'post' then 't3_' + after_id
					when 'message' then 't4_' + after_id
					when 'subreddit' then 't5_' + after_id
				query.set('after', after_fullname)
	path_string = path.join('/')
	if query.toString()
		path_string = path_string + '?' + query.toString()
	return path_string