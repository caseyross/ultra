import ID from '../../core/ID.coffee'

export default {
	
	comment_vote:
		targetID: (comment_short_id) ->
			ID('comment', comment_short_id)
		modify: (target, { numerical_vote }) ->
			original =
				likes: target.likes
			target.likes = numerical_vote
			return (target) ->
				target.likes = original.likes

}