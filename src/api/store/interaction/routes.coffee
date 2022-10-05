import { post } from '../../net/http.coffee'

export default {
	comment_reply: (comment_short_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t3_#{comment_short_id}"
		})
	comment_report: (comment_short_id) -> ({ additional_text, custom_text, site_rule, subreddit_name, subreddit_rule }) ->
		post("/api/report", {
			additional_info: additional_text
			api_type: 'json'
			custom_text: custom_text
			rule_reason: subreddit_rule
			site_reason: site_rule
			sr_name: subreddit_name
			thing_id: "t3_#{comment_short_id}"
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
	message_new: (user_name) -> ({ from_subreddit_name, subject, text }) ->
		post("/api/compose", {
			api_type: 'json'
			from_sr: from_subreddit_name
			subject: subject
			text: text
			to: user_name
		})
	message_reply: (message_short_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t4_#{message_short_id}"
		})
	message_report: (message_short_id) -> ({ additional_text, site_rule }) ->
		post("/api/report", {
			additional_info: additional_text
			api_type: 'json'
			from_modmail: false # TODO
			modmail_conv_id: null # TODO
			site_reason: site_rule
			thing_id: "t4_#{message_short_id}"
		})
	subreddit_subscription: (subreddit_name) -> ({ unsubscribe }) ->
		post("/api/subscribe", {
			action: if unsubscribe then 'unsub' else 'sub'
			skip_initial_defaults: if unsubscribe then null else true
			sr_name: subreddit_name
		})
	post_save: (post_short_id) -> ({ unsave }) ->
		post((if unsave then "/api/unsave" else "/api/save"), {
			id: "t3_#{post_short_id}"
		})
	post_reply: (post_short_id) -> ({ text }) ->
		post("/api/comment", {
			api_type: 'json'
			text: text
			thing_id: "t1_#{post_short_id}"
		})
	post_report: (post_short_id) -> ({ additional_text, custom_text, site_rule, subreddit_name, subreddit_rule }) ->
		post("/api/report", {
			additional_info: additional_text
			api_type: 'json'
			custom_text: custom_text
			rule_reason: subreddit_rule
			site_reason: site_rule
			sr_name: subreddit_name
			thing_id: "t1_#{post_short_id}"
		})
	post_vote: (post_short_id) -> ({ numerical_vote }) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t3_#{post_short_id}"
		})
}