# Docs: https://www.reddit.com/dev/api
import { API_GET, API_POST } from '/lib/apiPrimitives.coffee'
import Listing from '/objects/Listing'

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
				.then (rawListing) -> new Listing(rawListing)
			when 'u'
				limit ?= 25
				API_GET "/user/#{name}/overview",
					sort: broadRanking
					t: if broadRanking is 'top' or broadRanking is 'controversial' then narrowRanking else ''
					show: 'given'
					after: after
					limit: limit ? 25
				.then (rawListing) -> new Listing(rawListing)
			else
				limit = 0
				Promise.resolve(new Listing())
		return [0...limit].map((i) -> BATCH.then (listing) ->
			idMap[listing[i].id] = i
			return listing[i]
		)
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
			posts = new Listing(rawPostListing)
			post = posts[0]
			post.comments.list = new Listing(rawCommentListing)
			return post