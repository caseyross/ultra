# Separate and extract independent Reddit entities from raw API data.
# Primarily useful to parse Reddit's "Listing"/"Thing" data structures, and to flatten comment trees for store ingestion.
# NOTE: Side effects - modifies the input data!
export default generalExtractor = (rawData) ->
	result = {
		main: null # The object specified by an API route.
		sub: [] # Objects contained in the same API response as the main object, but which "belong" to a different API route.
	}
	switch rawData.kind
		when 'Listing'
			listing = rawData.data
			if !Array.isArray(listing.children) then listing.children = [] # [mutator]
			# Process and collect each item in the listing into "main", and all of their sub-items into "sub".
			result = listing.children.fold({ main: [], sub: [] }, (collected, item) ->
				{ main, sub } = generalExtractor(item)
				return
					main: collected.main.concat(main)
					sub: collected.sub.concat(sub)
			)
		when 't1'
			# NOTE: Comments in raw API data are structured as trees of comments containing other comments. Our main processing objective is to "de-link" these tree structures and subsequently identify comments by "flat" ID reference only.
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
				return repliesInTree
					.concat({ id: id('t1', main.id), data: main })
					.concat(sub)
			)
			# 2. Replace the replies in the original direct replies array with their IDs instead.
			comment.replies = comment.replies.map((directReply) -> id('t1', directReply.data.id)) # [mutator]
			result.main = comment
		when 't2'
			result.main = rawData.data
		when 't3'
			barePost = rawData.data
			if barePost.sr_detail
				result.sub.push({
					id: id('t5i', barePost.subreddit)
					data: barePost.sr_detail
					partial: true
				})
				delete barePost.sr_detail # [mutator]
			result.main = barePost
		when 't4'
			result.main = rawData.data
		when 't5'
			result.main = rawData.data
		when 't6'
			result.main = rawData.data
		else
			result.main = rawData
	return result 