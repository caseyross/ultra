import Anythings from './Anythings'

api_config = (type, name, sort) ->
	switch type
		when 'home'
			switch sort
				when 'hour', 'day', 'week', 'month', 'year', 'all'
					endpoint: 'top'
					query: { t: sort }
				when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
					endpoint: 'controversial'
					query: { t: sort[1..] }
				else
					endpoint: sort or ''
					query: {}
		when 'mail'
			endpoint: 'message/inbox'
		when 'profile'
			endpoint: 'user/' + name + '/overview'
			query: switch sort
				when 'hour', 'day', 'week', 'month', 'year', 'all'
					{ sort: 'top', t: sort }
				when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
					{ sort: 'controversial', t: sort[1..] }
				else
					{ sort: sort }
		when 'saved'
			endpoint: 'user/caseyross/saved'
		when 'subreddit'
			switch sort
				when 'hour', 'day', 'week', 'month', 'year', 'all'
					endpoint: 'r/' + name + '/top'
					query: { t: sort }
				when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
					endpoint: 'r/' + name + '/controversial'
					query: { t: sort[1..] }
				else
					endpoint: 'r/' + name + (if sort then '/' + sort else '') 
					query: {}

export default class Feed
	constructor: ({ prefix, name, sort, limit })->
		@type = switch prefix
			# i: private feeds
			when 'i'
				name
			# r: public subreddits and multireddits
			when 'r'
				if name.includes('-') then 'multireddit'
				else 'subreddit'
			# u: public user profiles
			when 'u'
				'profile'
		@name = name
		@sort = sort
		@limit = limit
		@PAGE = new LazyPromise => # PERF: May be faster to remove laziness, since this always needs to run ASAP after page load anyway
			API.get api_config(@type, @name, @sort).endpoint,
				{
					after: '',
					limit: @limit or 9,
					...api_config(@type, @name, @sort).query
				} 
			.then (data) ->
				next_after: data.data.after
				things: new Anythings(data)