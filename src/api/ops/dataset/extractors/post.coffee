import errors from '../../../base/errors.coffee'
import ID from '../../../base/ID.coffee'
import extract from '../extract.coffee'

# Our "post" API response type is slightly different from Reddit's "t3" kind.
# Reddit's "t3" kind refers only to bare posts, without their comment replies.
# Our "post" type refers to "complete" post objects, unifying posts and their comment replies.
# Extracting our desired format out of the API response requires special handling.
export default (rawData, sourceID) ->
	result =
		main: null
		sub: []
	# Normalize data structures from different API calls.
	if Array.isArray(rawData)
		postListing = rawData[0]
		commentsListing = rawData[1]
	else
		postListing = rawData
		commentsListing = null
	# Extract the bare post from the posts listing.
	# Put aside the other datasets from the posts listing for the end result.
	{ main: { data: post_ids }, sub: datasets } = extract(postListing)
	barePostDataset = datasets.find((dataset) -> ID.var(dataset.id, 1) == post_ids[0])
	otherDatasets = datasets.filter((dataset) -> ID.var(dataset.id, 1) != post_ids[0])
	# Process and organize the comment data, if present.
	if commentsListing
		# Keep the bare post as a sub-dataset and create a shallow-copy post object with added comment attributes as the main dataset. 
		post = { ...barePostDataset.data }
		# 1. Detect and process a "more comments" object.
		if commentsListing.data.children?.at(-1)?.kind is 'more'
			more = commentsListing.data.children.pop().data
			if more.count
				post.num_more_replies = more.count
				post.more_replies = if more.children.length then more.children else [more.id]
				post.more_replies_id = ID('post_more_replies', post.id, ID.var(sourceID, 2) ? 'confidence', ID.var(sourceID, 3), '', post.more_replies.join(','))
		# 2. Extract the comments from the listing.
		{ main: { data: direct_reply_ids }, sub: commentDatasets } = extract(commentsListing, sourceID)
		# 3. Link the top-level comments via their IDs.
		post.replies = direct_reply_ids
		# 4. Setup list of contributors for bulk access.
		contributor_ids = new Set()
		if post.author_fullname? then contributor_ids.add(post.author_fullname[3..])
		for commentDataset in commentDatasets
			if commentDataset.data.author_fullname? then contributor_ids.add(commentDataset.data.author_fullname[3..])
		post.contributors = Array.from(contributor_ids)
		# 5. Merge the extracted comment objects into the complete post data.
		result.main =
			id: null
			data: post
		result.sub = [barePostDataset].concat(otherDatasets.concat(commentDatasets))
	else
		if !barePostDataset
			throw new errors.DataNotAvailable({ code: '???', reason: 'unknown' })
		result.main = barePostDataset
	return result