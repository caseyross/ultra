import {
	fetchFrontpagePosts,
	fetchMultiredditPosts,
	fetchSubredditProfile,
	fetchSubredditPosts,
	fetchUserComments
	fetchUserProfile,
	fetchUserPosts
} from '../../logic/API.coffee'

export default class Listing

	constructor: (id) ->
		@id = id
		@type = 'frontpage'
		@name = 'frontpage'
		@source = {}
		@pagesize = NaN
		@posts = Promise.resolve([])
		@comments = Promise.resolve([])
		[ a, b, c, d, e ] = id.split('/')
		switch a
			when 'r'
				switch b
					when 'all', 'popular'
						@type = 'multireddit'
						@namespace = 'r'
						@name = b
					else
						@type = 'subreddit'
						@name = b
						@source = fetchSubredditProfile(b)
				if c
					@sort = c
					if d
						@sort = c + '/' + d
				else
					@sort = 'hot'
			when 'u'
				@type = 'user'
				@name = b
				@source = fetchUserProfile(b)
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
		switch @type
			when 'frontpage'
				@posts = fetchFrontpagePosts(@pagesize or 10, {@sort})
			when 'multireddit'
				@posts = fetchMultiredditPosts(@namespace, @name, @pagesize or 10, {@sort})
			when 'subreddit'
				@posts = fetchSubredditPosts(@name, @pagesize or 10, {@sort})
			when 'user'
				switch @filter
					when 'posts'
						@posts = fetchUserPosts(@name, @pagesize or 50, {@sort})
					when 'comments'
						@comments = fetchUserComments(@name, @pagesize or 100, {@sort})
					else
						@posts = fetchUserPosts(@name, @pagesize or 10, {@sort})
						@comments = fetchUserComments(@name, @pagesize or 20, {@sort})