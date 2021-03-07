import List from './List'
import Post from './Post'
import User from './User'

export default class Feed
	constructor: ({ name, url }) ->
		# parsed properties
		@domain = 'frontpage'
		@subdomain = ''
		@range = ''
		@ranking = ['best', '']
		@page_size = 10
		if name
			parts = name.split('/')
			if parts[0]
				@domain = parts[0]
			if parts[1]
				@subdomain = parts[1]
			if parts[2]
				@range = parts[2]
			switch @domain
				when 'r'
					@ranking = ['hot', '']
				when 'u', 'inbox', 'saved'
					@ranking = ['new', '']
		else
			path = url.pathname.split('/')
			query = new URLSearchParams(url.search)
			if path[1]
				switch path[1]
					when 'r'
						@domain = 'r'
						@ranking = if path[3] in ['new', 'rising', 'hot', 'best', 'top', 'controversial'] then [path[3], query.get('t') or ''] else ['hot', '']
					when 'u', 'user'
						@domain = 'u'
						@ranking = if query.get('sort') then [query.get('sort'), query.get('t') or ''] else ['new', '']
					when 'new', 'rising', 'hot', 'best', 'top', 'controversial'
						@ranking = [path[1], query.get('t') or '']
					else
						@domain = path[1]
						@ranking = ['new', '']
			if path[2]
				@subdomain = path[2]
			if path[3]
				@range = path[3]
			if query.get('limit')
				@page_size = query.get('limit')
		# derived properties
		@name = [@domain, @subdomain, @range].filter((x) -> x).join('/')
		@href = '/' + @name
		@owner = new User({
			name: switch @domain
					when 'inbox', 'saved' then 'me'
					when 'r' then 'reddit'
					when 'u' then @subdomain
					else @domain
		})
		@color = switch @domain
			when 'inbox' then 'indianred'
			when 'saved' then 'gold'
			when 'u' then 'cornflowerblue'
			else 'orangered'
		@flags =
			pure: @domain is 'r' and not (@subdomain in ['all', 'popular'] or @subdomain.startsWith('u_'))
		# mutable properties
		@data =
			# TODO: check for 403 response (not allowed to access subreddit)
			pages: [
				@page({})
			]
			about: new LazyPromise(=>
				switch @domain
					when 'r'
						Server.get({
							endpoint: '/r/' + @subdomain + '/about'
						}).then ({ data }) -> new FeedInfo(data)
					when 'u'
						Server.get({
							endpoint: '/user/' + @subdomain + '/about'
						}).then ({ data }) -> new FeedInfo(data)
					else
						Promise.resolve(null)
			)
	page: ({ after_id, seen_count }) => new LazyPromise(=>
		Server.get({
			endpoint: switch @domain
				when 'frontpage' then '/'
				when 'r' then '/r/' + @subdomain + '/' + @ranking[0]
				when 'u' then '/user/' + @subdomain + '/overview'
				when 'saved' then '/me/saved'
				when 'inbox' then '/message/inbox'
				else '/' # multireddits - TODO
			options:
				after: after_id
				count: seen_count
				limit: @page_size
				show: '' # TODO
				sort: @ranking[0]
				t: @ranking[1]
		}).then (listing) ->
			list = new List(listing)
			calc_hype(list.filter((x) -> x instanceof Post))
			return list
	)
calc_hype = (posts) ->
	now = Date.now()
	log_score_per_hour = (post) =>
		if Number.isFinite(post.meta.score)
			Math.log(post.meta.score / ((now - post.meta.submit_date.valueOf()) / 3600000))
		else
			NaN
	# calc distribution
	distribution = new NormalDistribution(posts.map((p) -> log_score_per_hour(p)).filter((x) -> Number.isFinite(x)))
	# calc and set each post's hype
	for post in posts
		post.meta.hype = distribution.deviation(log_score_per_hour(post))

class FeedInfo
	constructor: (r) ->
		@text =
			tagline: r.public_description_html
			sidebar: r.description_html
		@images =
			banner: r.banner_background_image or r.mobile_banner_image or r.banner_img or ''
			icon: r.community_icon or r.icon_img or ''
			header: r.header_img or ''
		@color = r.primary_color or r.key_color or 'transparent'
		@meta =
			create_date: new Date(r.created_utc * 1000)
			nsfw: r.over18
			online_user_count: r.active_user_count or r.accounts_active
			subscriber_count: r.subscribers