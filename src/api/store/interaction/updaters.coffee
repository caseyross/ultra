import ID from '../../core/ID.coffee'

export default {
	
	comment_save:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target, { unsave }) ->
			original =
				saved: target.saved
			target.saved = !unsave
			return (target) ->
				target.saved = original.saved
	
	comment_vote:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target, { numerical_vote }) ->
			original =
				likes: target.likes
				score: target.score
			if Number.isFinite(target.score)
				target.score = switch target.likes
					when true then target.score + numerical_vote - 1
					when null then target.score + numerical_vote
					when false then target.score + numerical_vote + 1
			target.likes = switch numerical_vote
				when 1 then true
				when 0 then null
				when -1 then false
			return (target) ->
				target.likes = original.likes
				target.score = original.score
	
	private_message_mark_read:
		targetID: (private_message_id) ->
			ID('private_message', private_message_id)
		modify: (target) ->
			original =
				read: target.read
			target.read = true
			return (target) ->
				target.read = original.read
	
	post_save:
		targetID: (post_id) ->
			ID('post', post_id)
		modify: (target, { unsave }) ->
			original =
				saved: target.saved
			target.saved = !unsave
			return (target) ->
				target.saved = original.saved

	post_vote:
		targetID: (post_id) ->
			ID('post', post_id)
		modify: (target, { numerical_vote }) ->
			original =
				likes: target.likes
				score: target.score
			if Number.isFinite(target.score) and target.score > 0 # unlikely to be able to change a 0 post score
				target.score = switch target.likes
					when true then target.score + numerical_vote - 1
					when null then target.score + numerical_vote
					when false then target.score + numerical_vote + 1
			target.likes = switch numerical_vote
				when 1 then true
				when 0 then null
				when -1 then false
			return (target) ->
				target.likes = original.likes
				target.score = original.score

	subreddit_subscription:
		targetID: (subreddit_name) ->
			ID('subreddit', subreddit_name)
		modify: (target, { unsubscribe }) ->
			original =
				user_is_subscriber: target.user_is_subscriber
			target.user_is_subscriber = !unsubscribe
			return (target) ->
				target.user_is_subscriber = original.user_is_subscriber

}