import ID from '../../core/ID.coffee'

export default {

	comment_reply:
		targetID: -> ({ parent_comment_id }) ->
			ID('comment', parent_comment_id)
		modify: (target, { id: new_comment_id }) ->
			target.replies.unshift(new_comment_id)

	post_reply:
		targetID: -> ({ post_id }) ->
			ID('post', post_id)
		modify: (target, { id: new_comment_id }) ->
			target.replies.unshift(new_comment_id)
	
}