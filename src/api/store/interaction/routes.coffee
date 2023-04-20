import { post } from '../../net/http.coffee'

export default {
	comment_edit: -> ({ comment_short_id, new_text }) ->
		post("/api/editusertext", {
			api_type: 'json'
			text: new_text
			thing_id: "t1_#{comment_short_id}"
		})
	comment_reply: -> ({ parent_comment_short_id, text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t1_#{parent_comment_short_id}"
		})
	comment_report: (comment_short_id) -> ({ freeform_report_text, rule_text, subreddit_name }) ->
		post("/api/report", {
			api_type: 'json'
			custom_text: freeform_report_text
			reason: rule_text
			sr_name: subreddit_name
			thing_id: "t1_#{comment_short_id}"
		})
	comment_save: (comment_short_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t1_#{comment_short_id}"
		})
	comment_vote: (comment_short_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t1_#{comment_short_id}"
		})
	message_new: -> ({ as_subreddit_name, body_text, subject, to_user_name }) ->
		post("/api/compose", {
			api_type: 'json'
			from_sr: as_subreddit_name
			subject: subject
			text: body_text
			to: to_user_name
		})
	message_reply: -> ({ parent_message_short_id, text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t4_#{parent_message_short_id}"
		})
	subreddit_subscribe: (subreddit_name) -> ({ unsubscribe }) ->
		post("/api/subscribe", {
			action: if unsubscribe then 'unsub' else 'sub'
			skip_initial_defaults: if unsubscribe then null else true
			sr_name: subreddit_name
		})
	post_edit: -> ({ post_short_id, new_text }) ->
		post("/api/editusertext", {
			api_type: 'json'
			text: new_text
			thing_id: "t3_#{post_short_id}"
		})
	post_save: (post_short_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t3_#{post_short_id}"
		})
	post_reply: -> ({ post_short_id, text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t3_#{post_short_id}"
		})
	post_report: (post_short_id) -> ({ freeform_report_text, rule_text, subreddit_name }) ->
		post("/api/report", {
			api_type: 'json'
			custom_text: freeform_report_text
			reason: rule_text
			sr_name: subreddit_name
			thing_id: "t3_#{post_short_id}"
		})
	post_vote: (post_short_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t3_#{post_short_id}"
		})
}