import ID from '../../core/ID.coffee'

export default {
	
	comment_vote:
		targetID: (comment_short_id) ->
			ID('comment', comment_short_id)
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

	post_vote:
		targetID: (post_short_id) ->
			ID('post', post_short_id)
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