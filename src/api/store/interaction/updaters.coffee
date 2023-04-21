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