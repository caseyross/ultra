import {
	getFrontpagePosts,
	getMultiredditPosts,
	getSubredditInfo,
	getSubredditPosts,
	getUserInfo,
	getUserSubmissions
} from '../functions/api/API.coffee'

# A channel represents the union of two related things that are, for practical reasons, separated in the Reddit API:
# 1. A Reddit object (generally a subreddit or user account)
# 2. The various data streams "owned" by that object (e.g. lists of posts, comments or messages)

export default class Channel

	constructor: (id) ->
		@id = id
		@type = 'frontpage'
		@name = 'frontpage'
		[ a, b, c, d, e ] = id.split('/')
		switch a
			when 'r'
				switch b
					when 'all', 'popular'
						@type = 'multireddit'
						@namespace = 'r'
						@name = 'r/' + b
					else
						@type = 'subreddit'
						@name = b
						@source = getSubredditInfo(b)
				if c
					@sort = c
					if d
						@sort = c + '/' + d
				else
					@sort = 'hot'
			when 'u'
				@type = 'user'
				@name = 'u/' + b
				@source = getUserInfo(b)
				switch c
					when 'new', 'hot', 'top', 'controversial'
						@sort = c
						if d
							@sort = c + '/' + d
					else
						if c
							@filter = c
							if d
								@sort = d
								if e
									@sort = d + '/' + e
						else
							@sort = 'new'

	getItems: (quantity) =>
		switch @type
			when 'frontpage'
				getFrontpagePosts({ @sort, quantity })
			when 'subreddit'
				getSubredditPosts(@name, { @sort, quantity })
			when 'multireddit'
				getMultiredditPosts(@namespace, @name, { @sort, quantity })
			when 'user'
				getUserSubmissions(@name, { @filter, @sort, quantity })