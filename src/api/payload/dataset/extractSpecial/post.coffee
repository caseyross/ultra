import extract from '../extract.coffee'
import ID from '../../ID.coffee'

# Our "post" API response type is slightly different from Reddit's "t3" kind.
# Reddit's "t3" kind refers only to bare posts, without their comment replies.
# Our "post" type refers to "complete" post objects, unifying posts and their comment replies.
# Extracting our desired format out of the API response requires special handling.
export default (rawData, sourceID) ->
	result =
		main: null
		sub: []
	# Extract the bare post from the posts listing.
	# Put aside the other datasets from the posts listing for the end result.
	{ main: { data: postShortIds }, sub: datasets } = extract(rawData[0])
	postDataset = datasets.find((dataset) -> ID.body(dataset.id)[0] == postShortIds[0])
	otherDatasets = datasets.filter((dataset) -> ID.body(dataset.id)[0] != postShortIds[0])
	post = postDataset.data
	# Process and organize the comment data.
	# 1. Detect and process a "more comments" object.
	if rawData[1].data.children?.at(-1)?.kind is 'more'
		more = rawData[1].data.children.pop()
		post.more_replies = more.data.children
		post.more_replies_id = ID.dataset('post_more_replies', post.id, '', ID.body(sourceID)[1] ? 'confidence', ...post.more_replies)
	# 2. Extract the comments from the listing.
	{ main: { data: topLevelCommentIds }, sub: commentDatasets } = extract(rawData[1], sourceID)
	# 3. Link the top-level comments via their IDs.
	post.replies = topLevelCommentIds
	# 4. Setup bulk user information leads.
	post.user_tranches = []
	user_short_ids_tranch = new Set()
	if post.author_fullname? then user_short_ids_tranch.add(post.author_fullname[3..])
	for commentDataset in commentDatasets
		if commentDataset.data.author_fullname? then user_short_ids_tranch.add(commentDataset.data.author_fullname[3..])
		if user_short_ids_tranch.size == 500
			post.user_tranches.push(ID.dataset('users', ...user_short_ids_tranch))
			user_short_ids_tranch.clear()
	if user_short_ids_tranch.size > 0
		post.user_tranches.push(ID.dataset('users', ...user_short_ids_tranch))
	# 5. Merge the extracted comment objects into the complete post data.
	result.main =
		id: postDataset.id
		data: post
	result.sub = otherDatasets.concat(commentDatasets)
	return result