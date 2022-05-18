import format from '../../../infra/format.coffee'
import extract from '../general/extract.coffee'

# Our "post" API response type is slightly different from Reddit's "t3" kind.
# Reddit's "t3" kind refers only to bare posts, without their comment replies.
# Our "post" type refers to "complete" post objects, unifying posts and their comment replies.
# Extracting our desired format out of the API response requires special handling.
export default (rawData) ->
	result =
		main: null
		sub: []
	# Extract the bare post from the posts listing.
	# Put aside the other datasets from the posts listing for the end result.
	{ main: { data: ids }, sub: datasets } = extract(rawData[0])
	[ posts, other ] = datasets.partition((dataset) -> dataset.id == ids[0])
	post = posts[0].data
	# Process and organize the comment data.
	# 1. Detect and process a "more comments" object.
	if rawData[1].data.children?.last?.kind is 'more'
		more = rawData[1].data.children.pop()
		post.more_replies = more.data.children.map((child) -> format.datasetId('comment', child))
	# 2. Extract the comments from the listing.
	{ main: { data: topLevelCommentIds }, sub: commentDatasets } = extract(rawData[1])
	# 3. Link the top-level comments via their IDs.
	post.replies = topLevelCommentIds
	# 4. Setup bulk comment author information leads.
	post.reply_author_info_tranches = []
	reply_author_short_ids_tranch = new Set()
	for commentDataset in commentDatasets
		if commentDataset.data.author_fullname? then reply_author_short_ids_tranch.add(commentDataset.data.author_fullname[3..])
		if reply_author_short_ids_tranch.size == 500
			post.reply_author_info_tranches.push(format.datasetId('user_info_bulk', ...reply_author_short_ids_tranch))
			reply_author_short_ids_tranch.clear()
	if reply_author_short_ids_tranch.size > 0
		post.reply_author_info_tranches.push(format.datasetId('user_info_bulk', ...reply_author_short_ids_tranch))
	# 5. Merge the extracted comment objects into the complete post data.
	result.main =
		id: posts[0].id
		data: post
	result.sub = other.concat(commentDatasets)
	return result