import { post } from '../../net/http.coffee'

export default {
	comment_approve: (comment_id) -> () ->
		post("/api/approve", {
			id: "t1_#{comment_id}"
		})
	comment_distinguish: (comment_id) -> ({ type }) ->
		post("/api/distinguish", {
			api_type: 'json'
			how: if type is 'moderator' then 'yes' else 'no'
			id: "t1_#{comment_id}"
			sticky: false
		})
	comment_edit: (comment_id) -> ({ new_text }) ->
		post("/api/editusertext", {
			api_type: 'json'
			text: new_text
			thing_id: "t1_#{comment_id}"
		})
	comment_ignore_reports: (comment_id) -> () ->
		post("/api/ignore_reports", {
			id: "t1_#{comment_id}"
		})
	comment_pin: (comment_id) -> ({ unpin }) ->
		post("/api/distinguish", {
			api_type: 'json'
			how: 'yes'
			id: "t1_#{comment_id}"
			sticky: !unpin
		})
	comment_remove: (comment_id) -> () ->
		post("/api/remove", {
			id: "t1_#{comment_id}"
			spam: false
		})
	comment_reply: (parent_comment_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t1_#{parent_comment_id}"
		})
	# note: freeform reports work the same way as specific rule violations; they are both just text
	comment_report: (comment_id) -> ({ violation_reason }) ->
		post("/api/report", {
			api_type: 'json'
			reason: violation_reason
			thing_id: "t1_#{comment_id}"
		})
	comment_save: (comment_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t1_#{comment_id}"
		})
	comment_vote: (comment_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t1_#{comment_id}"
		})
	message_compose: -> ({ as_subreddit_name, body_text, subject, to_user_name }) ->
		post("/api/compose", {
			api_type: 'json'
			from_sr: as_subreddit_name
			subject: subject
			text: body_text
			to: to_user_name
		})
	message_read: (message_id) -> ({ unread }) ->
		post((if unread then "/api/unread_message" else "/api/read_message"), {
			id: "t4_#{message_id}"
		})
	message_reply: (parent_message_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t4_#{parent_message_id}"
		})
	message_report: (message_id) -> ({ violation_reason }) ->
		post("/api/report", {
			api_type: 'json'
			reason: violation_reason
			thing_id: "t4_#{message_id}"
		})
	post_approve: (post_id) -> () ->
		post("/api/approve", {
			id: "t3_#{post_id}"
		})
	post_ignore_reports: (post_id) -> () ->
		post("/api/ignore_reports", {
			id: "t3_#{post_id}"
		})
	post_remove: (post_id) -> () ->
		post("/api/remove", {
			id: "t3_#{post_id}"
			spam: false
		})
	# note: requires additional comments parameters after post ID (as in `post` route) for the new reply to be automatically synced locally
	post_reply: (post_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t3_#{post_id}"
		})
	# note: freeform reports work the same way as specific rule violations; they are both just text
	post_report: (post_id) -> ({ violation_reason }) ->
		post("/api/report", {
			api_type: 'json'
			reason: violation_reason
			thing_id: "t3_#{post_id}"
		})
	post_save: (post_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t3_#{post_id}"
		})
	post_vote: (post_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t3_#{post_id}"
		})
	subreddit_subscribe: (subreddit_name) -> ({ unsubscribe }) ->
		post("/api/subscribe", {
			action: if unsubscribe then 'unsub' else 'sub'
			skip_initial_defaults: true
			sr_name: subreddit_name
		})
	user_ban: (user_name, subreddit_name) -> ({ days, message_to_user, violation_reason }) ->
		post("/r/#{subreddit_name}/api/friend", {
			api_type: 'json'
			ban_message: message_to_user
			ban_reason: violation_reason
			duration: Math.max(1, Math.min(days, 999)) # value must be between 1 and 999
			name: user_name
			type: 'banned'
		})

}