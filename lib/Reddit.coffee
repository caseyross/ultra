# Docs: https://www.reddit.com/dev/api
import { API_GET, API_POST } from '/lib/apiPrimitives'
import RedditListingSlice from '/objects/RedditListingSlice'

export default
	# Causes side effects (idMap).
	LISTING_SLICE: ({ id, sort, after, limit, idMap }) ->
		[ broadSort, narrowSort ] = sort.split('-')
		BATCH = switch id[0]
			when 'r'
				limit ?= 10
				API_GET (if id[2..] then "/#{id}/#{broadSort}" else "/#{broadSort}"),
					t: if broadSort is 'top' or broadSort is 'controversial' then narrowSort else ''
					after: after
					limit: limit
					show: 'all'
				.then (rawListing) -> new RedditListingSlice(rawListing)
			when 'u'
				limit ?= 25
				API_GET "/user/#{id[2..]}/overview",
					sort: broadSort
					t: if broadSort is 'top' or broadSort is 'controversial' then narrowSort else ''
					after: after
					limit: limit ? 25
					show: 'given'
				.then (rawListing) -> new RedditListingSlice(rawListing)
			else
				limit = 0
				Promise.resolve(new RedditListingSlice())
		return [0...limit].map((i) -> BATCH.then (listing) ->
			if not listing[i]? then return null
			idMap[listing[i].id] = i
			return listing[i]
		).filter((item) -> item)
	LISTING_ABOUT: ({ id }) ->
		if not id[2..]
			Promise.resolve null
		else
			API_GET "/#{if id[0] is 'u' then 'user' else id[0]}/#{id[2..]}/about"
			.then (rawData) -> rawData.data
	POST: ({ id, commentId, commentContext }) ->
		API_GET "/comments/#{id}",
			comment: commentId
			context: commentContext
		.then ([ rawPostListing, rawCommentListing ]) ->
			posts = new RedditListingSlice(rawPostListing)
			post = posts[0]
			post.comments.list = new RedditListingSlice(rawCommentListing)
			return post