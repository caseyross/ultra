# Separate and extract independent Reddit entities from raw API data.
# Primarily useful to parse Reddit's "Listing"/"Thing" data structures, and to flatten comment trees for store ingestion.
# NOTE: Side effects - modifies the input data!
export default generalExtractor = (rawData) ->
	result = {
		main: null
		sub: []
	}
	switch rawData.kind
		when 'Listing'
			result.main = []
			if Array.isArray(rawData.data.children)
				# Process and collect each item in the listing. The result is a parallel object structure that maintains main/sub distinctions.
				result = rawData.data.children.fold(result, (allEntities, child) ->
					childEntities = generalExtractor(child)
					return {
						main: allEntities.main.concat(childEntities.main)
						sub: allEntities.sub.concat(childEntities.sub)
					}
				)
		when 't1'
			# Sanitize the comment's list of direct replies.
			if !Array.isArray(rawData.data.replies) then rawData.data.replies = [] # [mutator]
			# Detect and refactor a "continue this thread" link in the replies.
			if rawData.data.replies.last?.kind is 'more' and rawData.data.replies.last.depth >= 10
				rawData.data.replies.pop() # [mutator]
				rawData.data.deep_replies = true # [mutator]
			# Detect and refactor a "more comments" object in the replies.
			if rawData.data.replies.last?.kind is 'more'
				more = rawData.data.replies.pop() # [mutator]
				rawData.data.more_replies = more.data.children # [mutator]
			# Collect all comments from the tree below this comment. The result is a linear array of such comments.
			result.sub = rawData.data.replies.fold(result.sub, (allSubEntities, child) ->
				childEntities = generalExtractor(child)
				return allSubEntities.concat([{
					id: id('t1', childEntities.main.id)
					status: 'complete'
					data: childEntities.main
				}]).concat(childEntities.sub)
			)
			# In the list of direct replies to this comment, replace the result with their IDs.
			rawData.data.replies = rawData.data.replies.map (child) -> id('t1', child.data.id) # [mutator]
			result.main = rawData.data
		when 't2'
			result.main = rawData.data
		when 't3'
			if rawData.data.sr_detail
				result.sub.push({
					id: id('t5i', rawData.data.subreddit)
					status: 'partial'
					data: rawData.data.sr_detail
				})
				delete rawData.data.sr_detail # [mutator]
			result.main = rawData.data
		when 't4'
			result.main = rawData.data
		when 't5'
			result.main = rawData.data
		when 't6'
			result.main = rawData.data
		else
			result.main = rawData
	return result 