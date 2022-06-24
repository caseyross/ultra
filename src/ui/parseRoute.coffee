INVALID = {
	path: 'invalid'
	data: null
}
TODO = {
	path: 'todo'
	data: null
}

export default (url) ->
	path = url.pathname.split('/')
	query = new URLSearchParams(url.search)
	if path[1] in ['de', 'es', 'fr', 'it', 'pt'] then path = path[1..]
	if path[1] is 'home' then path = path[1..]
	switch path[1]
		when undefined, '', 'best', 'controversial', 'hot', 'new', 'rising', 'top'
			sort = path[1] ? query.get('sort')
			switch sort
				when 'controversial', 'top'
					range = query.get('t')
					switch
						when range in ['hour', 'day', 'week', 'month', 'year', 'all']
							sort = sort + '_' + range
						else
							sort = sort + '_week'
				when 'best', 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
					break
				else
					sort = 'best'
			return {
				path: 'home'
				data:
					sort: sort
			}
		when 'm', 'multi', 'multireddit'
			user_name = path[2]
			multireddit_name = path[3]
			switch
				when !user_name? or !multireddit_name then return INVALID
				else break
			sort = path[4] ? query.get('sort')
			switch sort
				when 'controversial', 'top'
					range = query.get('t')
					switch
						when range in ['hour', 'day', 'week', 'month', 'year', 'all']
							sort = sort + '_' + range
						else
							sort = sort + '_month'
				when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
					break
				else
					sort = 'hot'
			return {
				path: 'multireddit'
				data:
					multireddit_name: multireddit_name
					sort: sort
					user_name: user_name
			}
		when 'mail', 'message', 'messages' then return TODO
		when 'p', 'post'
			id = path[2]
			switch
				when !id? then return INVALID
				else break
			sort = query.get('sort')
			switch sort
				when 'best', 'controversial', 'new', 'old', 'qa', 'top'
					break
				else
					sort = 'best'
			comment_id = path[4]
			comment_context = query.get('context')
			return {
				path: 'post'
				data:
					comment_id: comment_id
					comment_context: comment_context
					id: id
					sort: sort
			}
		when 'r', 'reddit', 'subreddit'
			filter = path[3]
			id = path[4]
			switch
				when filter is 'comments' and id?
					sort = query.get('sort')
					switch sort
						when 'best', 'controversial', 'new', 'old', 'qa', 'top'
							break
						else
							sort = 'best'
					comment_id = path[6]
					comment_context = query.get('context')
					return {
						path: 'post'
						data:
							comment_id: comment_id
							comment_context: comment_context
							id: id
							sort: sort
					}
				when filter is 'search' then return TODO
				when filter is 'wiki'
					subreddit_name = path[2]
					switch
						when !subreddit_name? then return INVALID
						when subreddit_name.length < 2 then return INVALID
						else break
					page_name = path[4]
					switch
						when !page_name? then page_name = 'index'
						else break
					revision_id = query.get('v')
					return {
						path: 'wiki_page'
						data:
							page_name: page_name
							revision_id: revision_id
							subreddit_name: subreddit_name
					}
				else
					name = path[2]
					switch
						when !name? then return INVALID
						when name.length < 2 then return INVALID
						when name is 'all'
							sort = path[3] ? query.get('sort')
							switch sort
								when 'controversial', 'top'
									range = query.get('t')
									switch
										when range in ['hour', 'day', 'week', 'month', 'year', 'all']
											sort = sort + '_' + range
										else
											sort = sort + '_week'
								when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
									break
								else
									sort = 'hot'
							return {
								path: 'all'
								data:
									sort: sort
							}
						when name is 'mod' then return TODO
						when name is 'popular'
							sort = path[3] ? query.get('sort')
							switch sort
								when 'controversial', 'top'
									range = query.get('t')
									switch
										when range in ['hour', 'day', 'week', 'month', 'year', 'all']
											sort = sort + '_' + range
										else
											sort = sort + '_week'
								when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
									break
								else
									sort = 'hot'
							geo_filter = query.get('geo_filter')
							switch
								when !geo_filter?
									geo_filter = 'GLOBAL'
								else
									break
							return {
								path: 'popular'
								data:
									geo_filter: geo_filter
									sort: sort
							}
						else
							sort = path[3] ? query.get('sort')
							switch sort
								when 'controversial', 'top'
									range = query.get('t')
									switch
										when range in ['hour', 'day', 'week', 'month', 'year', 'all']
											sort = sort + '_' + range
										else
											sort = sort + '_month'
								when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
									break
								else
									sort = 'hot'
							return {
								path: 'subreddit'
								data:
									name: name
									sort: sort
							}
		when 's', 'search' then return TODO
		when 'u', 'user'
			name = path[2]
			switch
				when !name? then return INVALID
				else break
			filter = path[3]
			switch filter
				when 'comments'
					break
				when 'm', 'multi', 'multireddit'
					user_name = name
					multireddit_name = path[4]
					switch
						when !user_name? or !multireddit_name then return INVALID
						else break
					sort = path[5] ? query.get('sort')
					switch sort
						when 'controversial', 'top'
							range = query.get('t')
							switch
								when range in ['hour', 'day', 'week', 'month', 'year', 'all']
									sort = sort + '_' + range
								else
									sort = sort + '_month'
						when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
							break
						else
							sort = 'hot'
					return {
						path: 'multireddit'
						data:
							multireddit_name: multireddit_name
							sort: sort
							user_name: user_name
					}
				when 'submitted'
					filter = 'posts'
				else
					filter = 'posts_and_comments'
			sort = query.get('sort')
			switch sort
				when 'controversial', 'top'
					range = query.get('t')
					switch
						when range in ['hour', 'day', 'week', 'month', 'year', 'all']
							sort = sort + '_' + range
						else
							sort = sort + '_all'
				when 'controversial_hour', 'controversial_day', 'controversial_week', 'controversial_month', 'controversial_year', 'controversial_all', 'hot', 'new', 'rising', 'top_hour', 'top_day', 'top_week', 'top_month', 'top_year', 'top_all'
					break
				else
					sort = 'new'
			return {
				path: 'user'
				data:
					filter: filter
					name: name
					sort: sort
			}
		when 'w', 'wiki'
			subreddit_name = path[2]
			switch
				when !subreddit_name? then return INVALID
				when subreddit_name.length < 2 then return INVALID
				else break
			page_name = path[3]
			switch
				when !page_name? then page_name = 'index'
				else break
			revision_id = query.get('v')
			return {
				path: 'wiki_page'
				data:
					page_name: page_name
					revision_id: revision_id
					subreddit_name: subreddit_name
			}
		else return INVALID