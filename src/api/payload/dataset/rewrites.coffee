import ID from '../ID.coffee'

export default {

	post_more_replies:
		targetID: (id) ->
			post_short_id = ID.body(id)[0]
			comment_short_id = ID.body(id)[1]
			return if comment_short_id then ID.dataset('comment', comment_short_id) else ID.dataset('post', post_short_id)
		transform: ({ replies, more_replies, more_replies_id, num_more_replies }) -> (target) ->
			delete target.more_replies
			delete target.more_replies_id
			delete target.num_more_replies
			if more_replies
				target.more_replies = more_replies
				target.more_replies_id = more_replies_id
				target.num_more_replies = num_more_replies
			target.replies.push(...replies)
			return target

}