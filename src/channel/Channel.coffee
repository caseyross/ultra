import {
	getFrontpagePosts
	getMultiredditPosts
	getSubredditInformation
	getSubredditPosts
	getUserComments
	getUserInformation
	getUserItems
	getUserPosts
} from '../API.coffee'

# A channel represents any Reddit data source that can provide a list of posts, comments, and/or messages.
# A channel may have a source representing where that list originates.
export default class Channel

	constructor: (id) ->
		@id = id
		@type = 'frontpage'
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
						@source = getSubredditInformation(b)
				if c
					@sort = c
					if d
						@sort = c + '/' + d
			when 'u'
				@type = 'user'
				@name = b
				@source = getUserInformation(b)
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

	getItems: (quantity) =>
		switch @type
			when 'frontpage'
				getFrontpagePosts({ @sort, quantity })
			when 'subreddit'
				getSubredditPosts(@name, { @sort, quantity })
			when 'multireddit'
				getMultiredditPosts(@namespace, @name, { @sort, quantity })
			when 'user'
				getUserItems(@name, { @filter, @sort, quantity })