import ID from '../../../core/ID.coffee'
import extract from './extract.coffee'

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
	{ main: { data: post_short_ids }, sub: datasets } = extract(rawData[0])
	postDataset = datasets.find((dataset) -> ID.var(dataset.id, 1) == post_short_ids[0])
	otherDatasets = datasets.filter((dataset) -> ID.var(dataset.id, 1) != post_short_ids[0])
	post = postDataset.data
	# Process and organize the comment data.
	# 1. Detect and process a "more comments" object.
	if rawData[1].data.children?.at(-1)?.kind is 'more'
		more = rawData[1].data.children.pop().data
		if more.count
			post.num_more_replies = more.count
			post.more_replies = if more.children.length then more.children else [more.id]
			post.more_replies_id = ID('post_more_replies', post.id, '', ID.var(sourceID, 2) ? 'confidence', ...post.more_replies)
	# 2. Extract the comments from the listing.
	{ main: { data: direct_reply_short_ids }, sub: commentDatasets } = extract(rawData[1], sourceID)
	# 3. Link the top-level comments via their IDs.
	post.replies = direct_reply_short_ids
	# 4. Setup list of contributors for bulk access.
	contributor_short_ids = new Set()
	if post.author_fullname? then contributor_short_ids.add(post.author_fullname[3..])
	for commentDataset in commentDatasets
		if commentDataset.data.author_fullname? then contributor_short_ids.add(commentDataset.data.author_fullname[3..])
	post.contributors = Array.from(contributor_short_ids)
	# 5. Merge the extracted comment objects into the complete post data.
	result.main =
		id: postDataset.id
		data: post
	result.sub = otherDatasets.concat(commentDatasets)
	return result