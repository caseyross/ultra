import extract from '../extract.coffee'
import ID from '../../ID.coffee'

# Unlike the initially-loaded comments for posts, "more children" results are provided as flat lists instead of trees.
export default (rawData, sourceID) ->
	result =
		main:
			id: null
			data:
				replies: []
		sub: []
	if rawData?.json?.data?.things?.length
		comments = {}
		mores = []
		# Start with some basic organization.
		for thing in rawData.json.data.things
			if thing.kind is 'more'
				mores.push(thing.data)
			else if thing.kind is 't1'
				comments[thing.data.id] = extract(thing, sourceID).main
		source_comment_short_id = ID.body(sourceID)[1]
		# Link up child comments onto their parents.
		for comment_short_id, comment of comments
			parent = switch
				when comment.data.parent_id.startsWith('t3_') then result.main.data
				when comment.data.parent_id.startsWith('t1_')
					if comment.data.parent_id[3..] is source_comment_short_id then result.main.data
					else comments[comment.data.parent_id[3..]].data
			parent.replies.push(comment_short_id)
		# Record "more children" properties for comments.
		for more of mores
			if more.count
				parent = switch
					when more.parent_id.startsWith('t3_') then result.main.data
					when more.parent_id.startsWith('t1_')
						if more.parent_id[3..] is source_comment_short_id then result.main.data
						else comments[more.parent_id[3..]].data
				parent.num_more_replies = more.count
				parent.more_replies = if more.children.length then more.children else [more.id]
				parent.more_replies_id = ID.dataset(
					'post_more_replies',
					ID.body(sourceID)[0],
					parent.id ? ID.body(sourceID)[1],
					ID.body(sourceID)[2],
					...parent.more_replies
				)
		result.sub = Object.values(comments)
	return result