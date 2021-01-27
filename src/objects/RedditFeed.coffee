import RedditList from '/src/objects/RedditList'
import RedditUser from '/src/objects/RedditUser'

export default class RedditFeed
	constructor: ({ fromId, fromUrl }) ->
		# parsed properties
		@domain = 'frontpage'
		@subdomain = ''
		@range = ''
		@rankBy = ['best', '']
		@limit = 10
		if fromId
			parts = fromId.split('/')
			if parts[0]
				@domain = parts[0]
			if parts[1]
				@subdomain = parts[1]
			if parts[2]
				@range = parts[2]
			switch @domain
				when 'r'
					@rankBy = ['hot', '']
				when 'u', 'inbox', 'saved'
					@rankBy = ['new', '']
		else
			path = fromUrl.pathname.split('/')
			query = new URLSearchParams(fromUrl.search)
			if path[1]
				switch path[1]
					when 'r'
						@domain = 'r'
						@rankBy = if path[3] in ['new', 'rising', 'hot', 'best', 'top', 'controversial'] then [path[3], query.get('t') or ''] else ['hot', '']
					when 'u', 'user'
						@domain = 'u'
						@rankBy = if query.get('sort') then [query.get('sort'), query.get('t') or ''] else ['new', '']
					when 'new', 'rising', 'hot', 'best', 'top', 'controversial'
						@rankBy = [path[1], query.get('t') or '']
					else
						@domain = path[1]
						@rankBy = ['new', '']
			if path[2]
				@subdomain = path[2]
			if path[3]
				@range = path[3]
			if query.get('limit')
				@limit = query.get('limit')
		# derived properties
		@id = [@domain, @subdomain, @range].join('/')
		@href = '/' + @id
		@owner = switch @domain
			when 'inbox', 'saved' then new RedditUser('me')
			when 'r' then new RedditUser('reddit')
			when 'u' then new RedditUser(@subdomain)
			else new RedditUser(@domain)
		@color = switch @domain
			when 'inbox' then 'indianred'
			when 'saved' then 'gold'
			when 'u' then 'cornflowerblue'
			else 'orangered'
		@flags =
			pure: @domain is 'r' and not (@subdomain in ['all', 'popular'] or @subdomain.startsWith('u_'))
		# mutable properties
		@endId = ''
		@fragments = [
			@nextFragment
		]
	about: () =>
		switch @domain
			when 'r'
				Api.get('/r/' + @subdomain + '/about').then ({ data }) -> data
			when 'u'
				Api.get('/user/' + @subdomain + '/about').then ({ data }) -> data
			else
				Promise.resolve {}
	nextFragment: () =>
		endpoint = switch @domain
			when 'frontpage' then '/'
			when 'r' then '/r/' + @subdomain + '/' + @rankBy[0]
			when 'u' then '/user/' + @subdomain + '/overview'
			when 'saved' then '/me/saved'
			when 'inbox' then '/message/inbox'
			else '/' # multireddits - TODO
		options =
			after: '' # TODO
			count: '' # TODO
			limit: @limit
			show: '' # TODO
			sort: @rankBy[0]
			t: @rankBy[1]
		Api.get(endpoint, options).then (rawListing) =>
			@endId = rawListing?.data?.after
			new RedditList(rawListing)