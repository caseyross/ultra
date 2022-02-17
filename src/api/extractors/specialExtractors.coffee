import generalExtractor from './generalExtractor.coffee'

# Note: Expect side effects in all extractors!
export default {

	t3: (rawData) ->
		# Our "t3" API response type is slightly different from Reddit's "t3" kind.
		# Reddit's "t3" kind refers only to bare posts, without their comment replies.
		# Our "t3" type refers to "complete" post objects, unifying posts and their comment replies.
		# Extracting our desired format out of the API response requires special handling.
		if !Array.isArray(rawData[1].data.children) then rawData[1].data.children = [] # [mutator]
		# Detect and process a "more comments" object.
		if rawData[1].data.children.last?.kind is 'more'
			more = rawData[1].data.children.pop() # [mutator]
			rawData[0].data.children[0].data.more_replies = more.data.children # [mutator]
		# Save the IDs of the post's direct replies onto the post data.
		rawData[0].data.children[0].data.replies = rawData[1].data.children.map (rawCommentData) -> id('t1', rawCommentData.id) # [mutator]
		rawPost = rawData[0].data.children[0]
		# Extract the entities, and collect and unify the post with its comments.
		[postEntities, commentEntities] = rawData.map generalExtractor
		return {
			main: postEntities.main[0]
			sub: postEntities.sub.concat(
				commentEntities.main.map((entity) ->
					return {
						id: id('t1', entity.id)
						status: 'complete'
						data: entity
					}
				)
			).concat(commentEntities.sub)
		}

}