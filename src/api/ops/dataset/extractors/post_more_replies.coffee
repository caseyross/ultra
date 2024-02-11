import ID from '../../../base/ID.coffee'
import extract from '../extract.coffee'

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
		source_comment_id = ID.var(sourceID, 4)
		# Link up child comments onto their parents.
		for comment_id, comment of comments
			parent = switch
				when comment.data.parent_id.startsWith('t3_') then result.main.data
				when comment.data.parent_id.startsWith('t1_')
					if comment.data.parent_id[3..] is source_comment_id then result.main.data
					else comments[comment.data.parent_id[3..]].data
			parent.replies.push(comment_id)
		# Record "more children" properties for comments.
		for more in mores
			if more.count
				parent = switch
					when more.parent_id.startsWith('t3_') then result.main.data
					when more.parent_id.startsWith('t1_')
						if more.parent_id[3..] is source_comment_id then result.main.data
						else comments[more.parent_id[3..]].data
				parent.num_more_replies = more.count
				parent.more_replies = if more.children.length then more.children else [more.id]
				parent.more_replies_id = ID(
					'post_more_replies',
					ID.var(sourceID, 1),
					ID.var(sourceID, 2),
					ID.var(sourceID, 3),
					parent.id ? source_comment_id,
					parent.more_replies.join(',')
				)
		result.sub = Object.values(comments)
	return result