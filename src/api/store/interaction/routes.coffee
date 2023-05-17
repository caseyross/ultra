import { post } from '../../net/http.coffee'

export default {
	comment_edit: (comment_id) -> ({ new_text }) ->
		post("/api/editusertext", {
			api_type: 'json'
			text: new_text
			thing_id: "t1_#{comment_id}"
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
	private_message_mark_read: (private_message_id) -> ({ unread }) ->
		post((if unread then "/api/unread_message" else "/api/read_message"), {
			id: "t4_#{private_message_id}"
		})
	private_message_new: -> ({ as_subreddit_name, body_text, subject, to_user_name }) ->
		post("/api/compose", {
			api_type: 'json'
			from_sr: as_subreddit_name
			subject: subject
			text: body_text
			to: to_user_name
		})
	private_message_reply: (parent_private_message_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t4_#{parent_private_message_id}"
		})
	subreddit_subscribe: (subreddit_name) -> ({ unsubscribe }) ->
		post("/api/subscribe", {
			action: if unsubscribe then 'unsub' else 'sub'
			skip_initial_defaults: if unsubscribe then null else true
			sr_name: subreddit_name
		})
	post_save: (post_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t3_#{post_id}"
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
	post_vote: (post_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t3_#{post_id}"
		})
}