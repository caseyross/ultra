import { post } from '../../network/http.coffee'

export default {
	save_comment: (comment_short_id) ->
		post("/api/vote", {
			id: "t1_#{comment_short_id}"
		})
	save_post: (post_short_id) ->
		post("/api/vote", {
			id: "t3_#{post_short_id}"
		})
	vote_comment: (comment_short_id, numerical_vote) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t1_#{comment_short_id}"
		})
	vote_post: (post_short_id, numerical_vote) ->
		post("/api/vote", {
			dir: numerical_vote
			id: "t3_#{post_short_id}"
		})
}