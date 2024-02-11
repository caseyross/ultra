import ID from '../../base/ID.coffee'

export default {

	post:
		targetID: (post_id, comments_sort, max_comments, focus_comment_id, focus_comment_parent_count) ->
			if focus_comment_id
				ID('comment', focus_comment_id)
			else
				null
		modify: (target) ->
			delete target.deeper_replies
			delete target.deeper_replies_id

	post_more_replies:
		targetID: (post_id, post_comments_sort, post_max_comments, parent_comment_id) ->
			if parent_comment_id
				ID('comment', parent_comment_id)
			else
				ID('post', post_id, post_comments_sort, post_max_comments)
		modify: (target, { more_replies, more_replies_id, num_more_replies, replies }) ->
			delete target.more_replies
			delete target.more_replies_id
			delete target.num_more_replies
			if more_replies
				target.more_replies = more_replies
				target.more_replies_id = more_replies_id
				target.num_more_replies = num_more_replies
			target.replies.push(...replies)

}