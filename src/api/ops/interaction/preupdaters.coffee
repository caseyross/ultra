import { Time } from '../../../lib/index.js'
import ID from '../../base/ID.coffee'
import { getUser } from '../../net/account.coffee'

export default {
	
	comment_approve:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target) ->
			original =
				approved_at_utc: target.approved_at_utc
				approved_by: target.approved_by
			target.approved_at_utc = Time.msToS(Time.unixMs(), { trunc: true })
			target.approved_by = getUser()
			return (target) ->
				target.approved_at_utc = original.approved_at_utc
				target.approved_by = original.approved_by
	
	comment_distinguish:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target, { type }) ->
			original =
				distinguished: target.distinguished
			target.distinguished = type or null
			return (target) ->
				target.distinguished = original.distinguished
	
	comment_pin:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target, { unpin }) ->
			original =
				distinguished: target.distinguished
				stickied: target.stickied
			target.distinguished = 'moderator'
			target.stickied = !unpin
			return (target) ->
				target.distinguished = original.distinguished
				target.stickied = original.stickied
	
	comment_remove:
		targetID: (comment_id) ->
			ID('comment', comment_id)
		modify: (target) ->
			original =
				removed_by: target.removed_by
				removed_by_category: target.removed_by_category
			target.removed_by = getUser()
			target.removed_by_category = 'moderator'
			return (target) ->
				target.removed_by = original.removed_by
				target.removed_by_category = original.removed_by_category
	
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
	
	message_read:
		targetID: (message_id) ->
			ID('message', message_id)
		modify: (target, { unread }) ->
			original =
				read: target.read
			target.read = !unread
			return (target) ->
				target.read = original.read
	
	post_approve:
		targetID: (post_id) ->
			ID('post', post_id)
		modify: (target) ->
			original =
				approved_at_utc: target.approved_at_utc
				approved_by: target.approved_by
			target.approved_at_utc = Time.msToS(Time.unixMs(), { trunc: true })
			target.approved_by = getUser()
			return (target) ->
				target.approved_at_utc = original.approved_at_utc
				target.approved_by = original.approved_by
	
	post_remove:
		targetID: (post_id) ->
			ID('post', post_id)
		modify: (target) ->
			original =
				removed_by: target.removed_by
				removed_by_category: target.removed_by_category
			target.removed_by = getUser()
			target.removed_by_category = 'moderator'
			return (target) ->
				target.removed_by = original.removed_by
				target.removed_by_category = original.removed_by_category
	
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

	subreddit_subscribe:
		targetID: (subreddit_name) ->
			ID('subreddit', subreddit_name)
		modify: (target, { unsubscribe }) ->
			original =
				user_is_subscriber: target.user_is_subscriber
			target.user_is_subscriber = !unsubscribe
			return (target) ->
				target.user_is_subscriber = original.user_is_subscriber

}