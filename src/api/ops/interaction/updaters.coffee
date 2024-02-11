import ID from '../../base/ID.coffee'

export default {

	comment_reply:
		targetID: (parent_comment_id) ->
			ID('comment', parent_comment_id)
		modify: (target, { id: new_comment_id }) ->
			target.replies.unshift(new_comment_id)

	post_reply:
		targetID: (post_id, comments_sort, max_comments, focus_comment_id, focus_comment_parent_count) ->
			ID('post', post_id, comments_sort, max_comments, focus_comment_id, focus_comment_parent_count)
		modify: (target, { id: new_comment_id }) ->
			target.replies.unshift(new_comment_id)

}