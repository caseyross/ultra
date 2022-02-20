# Separate and extract independent Reddit entities from raw API data.
# Primarily useful to parse Reddit's "Listing" and "Thing" data structures, and to flatten comment trees for store ingestion.
# All extractors return the same data structure. It is described below as it is constructed.
# NOTE: Contains side effects throughout (namely, input data modification).
export default generalExtractor = (rawData) ->
	result =
		main: null # The object specified by an API route.
		sub: [] # Objects contained in the same API response as the main objects, but which "belong" to a different API route.
	switch rawData.kind
		when 'Listing'
			listing = rawData.data
			if !Array.isArray(listing.children) then listing.children = [] # [mutator]
			# If each top-level object in the listing is referenceable by ID, the primary data becomes simply an array of IDs.
			# If not, the primary data contains the full child objects.
			listingDatasets = listing.children.map((item) -> generalExtractor(item))
			childIds = listingDatasets.map(({ main }) -> main.id)
			if childIds.all((id) -> id?)
				result.main =
					id: null # At the top level of the API response, we don't need this, as we already know which ID the data was requested for... (continues in comment extraction)
					data: childIds
				result.sub = listingDatasets.map(({ main, sub }) -> sub.concat(main))
			else
				result.main =
					id: null
					data: listingDatasets.map(({ main }) -> main)
				result.sub = listingDatasets.map(({ sub }) -> sub)
		when 't1'
			# NOTE: Comments in raw API data are structured as trees of comments containing other comments and various related objects. Our objective is to "de-link" these tree structures and subsequently identify comments entirely through direct ID reference.
			comment = rawData.data
			if !Array.isArray(comment.replies) then comment.replies = [] # [mutator]
			# Detect and process a "continue this thread" link in the comment's replies.
			if comment.replies.last?.kind is 'more' and comment.replies.last.depth >= 10
				comment.replies.pop() # [mutator]
				comment.deep_replies = true # [mutator]
			# Detect and process a "more comments" object in the comment's replies.
			if comment.replies.last?.kind is 'more'
				more = comment.replies.pop() # [mutator]
				comment.more_replies = more.data.children # [mutator]
			# Process the non-special replies to the comment.
			# 1. Recursively list every reply in the tree "below" this comment.
			result.sub = comment.replies.fold([], (repliesInTree, directReply) ->
				{ main, sub } = generalExtractor(directReply)
				repliesInTree.concat(main).concat(sub)
			)
			# 2. Replace the replies in the original direct replies array with their IDs instead.
			comment.replies = comment.replies.map((directReply) -> id('t1', directReply.id)) # [mutator]
			result.main =
				id: id('t1', rawData.id) # ...but when we recursively extract sub-objects, we need to identify them.
				data: comment
		when 't2'
			result.main =
				id: id('t2i', rawData.data.name.toLowerCase())
				data: rawData.data
		when 't3'
			barePost = rawData.data
			if barePost.sr_detail
				result.sub.push({
					id: id('t5i', barePost.subreddit.toLowerCase())
					data: barePost.sr_detail
					partial: true # Marks objects known to be an incomplete version of data from another API response.
				})
				delete barePost.sr_detail # [mutator]
			result.main =
				id: id('t3', rawData.id)
				data: barePost
		when 't4'
			result.main =
				id: id('t4', rawData.id)
				data: rawData.data
		when 't5'
			result.main =
				id: id('t5i', rawData.data.display_name.toLowerCase())
				data: rawData.data
		when 't6'
			result.main =
				id: id('t6', rawData.id)
				data: rawData.data
		else
			result.main =
				id: null
				data: rawData
	return result