# Separate and extract independent Reddit entities from raw API data.
# Primarily useful to parse Reddit's "Listing"/"Thing" data structures, and to flatten comment trees for store ingestion.
# NOTE: Side effects - modifies the input data!
export extractEntities = (rawData) ->
	objects = {
		main: null
		sub: []
	}
	switch rawData.kind
		when 'Listing'
			objects.main = []
			if Array.isArray(rawData.data.children)
				# Process and collect each item in the listing. The result is a parallel object structure that maintains main/sub distinctions.
				objects = rawData.data.children.fold(objects, (parentObjects, child) ->
					childObjects = extractEntities(child)
					return {
						main: parentObjects.main.concat(childObjects.main)
						sub: parentObjects.sub.concat(childObjects.sub)
					}
				)
		when 't1'
			# Sanitize the comment's list of direct replies.
			if !Array.isArray(rawData.data.replies)
				rawData.data.replies = [] # [mutator]
			# Detect and process a "continue this thread" link in the replies.
			if rawData.data.replies.length > 0 and rawData.data.replies.last().kind is 'more' and rawData.data.replies.last().depth >= 10
				rawData.data.replies.pop() # [mutator]
				rawData.data.deep_replies = true # [mutator]
			# Detect and process a "more comments" object in the replies.
			if rawData.data.replies.length > 0 and rawData.data.replies.last().kind is 'more'
				more = rawData.data.replies.pop() # [mutator]
				rawData.data.more_replies = more.data.children # [mutator]
			# Detect and process further (normal) replies.
			if rawData.data.replies.length > 0
				# Process and collect all replies from the tree under this comment. The result is a serial, single array.
				objects.sub = rawData.data.replies.fold(objects.sub, (parentSubObjects, child) ->
					childObjects = extractEntities(child)
					return parentSubObjects.concat([{
						id: childObjects.main.id
						status: 'complete'
						data: childObjects.main
					}]).concat(childObjects.sub)
				)
				# Substitute IDs in place of full objects in the list of direct replies for this comment.
				rawData.data.replies = rawData.data.replies.map (child) -> child.data.id # [mutator]
			objects.main = rawData.data
		when 't2'
			objects.main = rawData.data
		when 't3'
			if rawData.data.sr_detail
				objects.sub.push({
					id: 't5i_' + rawData.data.subreddit
					status: 'partial'
					data: rawData.data.sr_detail
				})
				delete rawData.data.sr_detail # [mutator]
			objects.main = rawData.data
		when 't4'
			objects.main = rawData.data
		when 't5'
			objects.main = rawData.data
		when 't6'
			objects.main = rawData.data
		else
			objects.main = rawData
	return objects 