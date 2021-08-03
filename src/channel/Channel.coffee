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
		[ a, b, c ] = id.split('/')
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
			when 'u'
				@type = 'user'
				@name = b
				@source = getUserInformation(b)

	getItems: (quantity) =>
		switch @type
			when 'frontpage'
				getFrontpagePosts({ quantity })
			when 'subreddit'
				getSubredditPosts(@name, { quantity })
			when 'multireddit'
				getMultiredditPosts(@namespace, @name, { quantity })
			when 'user'
				getUserItems(@name, { quantity })