# Docs: https://www.reddit.com/dev/api
import { API_GET, API_POST } from '/lib/apiPrimitives.coffee'
import Listing from '/objects/Listing'

export default
	FEED_SLICE: ({ type, name, ranking, after, limit }) ->
		[ broadRanking, narrowRanking ] = ranking.split('-')
		switch type
			when 'u'
				API_GET "/user/#{name}/overview",
					sort: broadRanking
					t: if broadRanking is 'top' or broadRanking is 'controversial' then narrowRanking else ''
					show: 'given'
					after: after
					limit: limit ? 25
				.then (listing) -> new Listing(listing)
			when 'r'
				API_GET (if name then "/r/#{name}/#{broadRanking}" else "/#{broadRanking}"),
					t: if broadRanking is 'top' or broadRanking is 'controversial' then narrowRanking else ''
					show: 'all'
					after: after
					limit: limit ? 10
				.then (listing) -> new Listing(listing)
	FEED_METADATA: ({ type, name }) ->
		if not name
			Promise.resolve({})
		else
			API_GET "/#{if type is 'u' then 'user' else type}/#{name}/about"
			.then ({ data }) -> data
	POST: ({ id, commentId, commentContext }) ->
		API_GET "/comments/#{id}",
			comment: commentId
			context: commentContext
		.then ([ postListing, commentListing ]) ->
			posts = new Listing(postListing)
			post = posts[0]
			post.comments.list = new Listing(commentListing)
			return post