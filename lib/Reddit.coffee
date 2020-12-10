# Docs: https://www.reddit.com/dev/api
import { API_GET, API_POST } from '/lib/apiPrimitives'
import RedditListing from '/objects/RedditListing'

export default
	## warning: side effects (idMap) ##
	FEED_SLICE: ({ type, name, ranking, after, limit, idMap }) ->
		[ broadRanking, narrowRanking ] = ranking.split('-')
		BATCH = switch type
			when 'r'
				limit ?= 10
				API_GET (if name then "/r/#{name}/#{broadRanking}" else "/#{broadRanking}"),
					t: if broadRanking is 'top' or broadRanking is 'controversial' then narrowRanking else ''
					show: 'all'
					after: after
					limit: limit
				.then (rawListing) -> new RedditListing(rawListing)
			when 'u'
				limit ?= 25
				API_GET "/user/#{name}/overview",
					sort: broadRanking
					t: if broadRanking is 'top' or broadRanking is 'controversial' then narrowRanking else ''
					show: 'given'
					after: after
					limit: limit ? 25
				.then (rawListing) -> new RedditListing(rawListing)
			else
				limit = 0
				Promise.resolve(new RedditListing())
		return [0...limit].map((i) -> BATCH.then (listing) ->
			if not listing[i]? then return null
			idMap[listing[i].id] = i
			return listing[i]
		).filter((item) -> item)
	FEED_METADATA: ({ type, name }) ->
		if not name
			Promise.resolve null
		else
			API_GET "/#{if type is 'u' then 'user' else type}/#{name}/about"
			.then (metadata) -> metadata.data
	FEED_POST: ({ id, commentId, commentContext }) ->
		API_GET "/comments/#{id}",
			comment: commentId
			context: commentContext
		.then ([ rawPostListing, rawCommentListing ]) ->
			posts = new RedditListing(rawPostListing)
			post = posts[0]
			post.comments.list = new RedditListing(rawCommentListing)
			return post