import { get, post } from '../../net/http.coffee'

export default {
	collection: (collection_short_id) ->
		get("/api/v1/collections/collection", {
			collection_id: collection_short_id
			include_links: true
		})
	current_user: ->
		get("/api/v1/me")
	current_user_messages: (max_messages, after_message_fullname) ->
		get("/message/inbox", {
			after: after_message_fullname
			limit: max_messages
			mark: false
			show: 'all'
		})
	current_user_settings: ->
		get("/api/v1/me/prefs")
	current_user_subscriptions: ->
		get("/subreddits/mine/subscriber", {
			limit: 100
			show: 'all'
			sr_detail: true
		})
	comment: (comment_short_id) ->
		get("/api/info", {
			id: "t1_#{comment_short_id}"
		})
	multireddit: (user_name, multireddit_name) ->
		if user_name is 'r' then Promise.resolve(null)
		else get("/api/multi/user/#{user_name}/m/#{multireddit_name}")
	multireddit_posts: (user_name, multireddit_name, posts_sort, max_posts, after_post_short_id) ->
		get(
			switch
				when user_name is 'r' and multireddit_name is 'home' then "/#{posts_sort.split('-')[0]}"
				when user_name is 'r' then "/r/#{multireddit_name}/#{posts_sort.split('-')[0]}"
				else "/user/#{user_name}/m/#{multireddit_name}/#{posts_sort.split('-')[0]}"
			{
				after: after_post_short_id and "t3_#{after_post_short_id}"
				limit: max_posts
				show: 'all'
				sr_detail: true
				t: posts_sort.split('-')[1]
			}
		)
	post: (post_short_id, comments_sort, max_comments, spotlight_comment_short_id, spotlight_comment_context) ->
		get("/comments/#{post_short_id}", {
			comment: spotlight_comment_short_id && "t1_#{spotlight_comment_short_id}"
			context: spotlight_comment_context
			limit: max_comments
			showedits: true
			showmedia: true
			showmore: true
			showtitle: true
			sort: comments_sort
		})
	post_duplicates: (post_short_id, max_posts, after_post_short_id) ->
		get("/duplicates/#{post_short_id}", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
		})
	post_more_replies: (post_short_id, parent_comment_short_id, comments_sort, ...comment_short_ids) -> # NOTE: Max concurrency for this call is 1 per Reddit rules.
		post("/api/morechildren", {
			api_type: 'json'
			children: 'c1:' + comment_short_ids.map((short_id) -> "t1_#{short_id}").join(',')
			link_id: "t3_#{post_short_id}"
			sort: comments_sort
		})
	search_posts: (time_range, search_text, max_posts, after_post_short_id) ->
		get("/search", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			q: search_text
			restrict_sr: false
			show: 'all'
			sort: 'relevance'
			t: time_range
		})
	search_posts_in_multireddit: (user_name, multireddit_name, time_range, search_text, max_posts, after_post_short_id) ->
		get("/user/#{user_name}/m/#{multireddit_name}/search", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			is_multi: 1
			q: search_text
			restrict_sr: true
			show: 'all'
			sort: 'relevance'
			t: time_range
		})
	search_posts_in_subreddit: (subreddit_name, time_range, search_text, max_posts, after_post_short_id) ->
		get("/r/#{subreddit_name}/search", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			q: search_text
			restrict_sr: true
			show: 'all'
			sort: 'relevance'
			t: time_range
		})
	search_subreddits: (search_text) ->
		get("/api/subreddit_autocomplete_v2", {
			include_over_18: true
			include_profiles: false
			limit: 10
			query: search_text # 1-25 chars
			typeahead_active: false
		})
	search_users: (search_text) ->
		get("/users/search", {
			limit: 10
			show: 'all'
			sort: 'relevance'
			q: search_text
			typeahead_active: false
		})
	subreddit: (subreddit_name) ->
		get("/r/#{subreddit_name}/about")
	subreddits_popular: (max_subreddits) ->
		get("/subreddits/popular", {
			limit: Number(max_subreddits) + 1 # actual number returned is limit minus 1
		})
	subreddit_emotes: (subreddit_name) ->
		get("/api/v1/#{subreddit_name}/emojis/all")
	subreddit_moderators: (subreddit_name, after_user_short_id) ->
		get("/r/#{subreddit_name}/about/moderators", {
			after: after_user_short_id and "t2_#{after_user_short_id}"
			limit: 100
			show: 'all'
		})
	subreddit_posts: (subreddit_name, posts_sort, max_posts, after_post_short_id) ->
		get("/r/#{subreddit_name}/#{posts_sort.split('-')[0]}", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			show: 'all'
			t: posts_sort.split('-')[1]
		})
	subreddit_post_flairs: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/link_flair_v2")
	subreddit_post_guidelines: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/submit_text")
	subreddit_post_requirements: (subreddit_name) ->
		get("/api/v1/#{subreddit_name}/post_requirements")
	subreddit_rules: (subreddit_name) ->
		get("/r/#{subreddit_name}/about/rules")
	subreddit_widgets: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/widgets")
	subreddit_user_flairs: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/user_flair_v2")
	user: (user_name) ->
		get("/user/#{user_name}/about", {
			sr_detail: true
		})
	users: (user_short_ids) ->
		get("/api/user_data_by_account_ids", {
			ids: user_short_ids.split(',').map((short_id) -> "t2_#{short_id}")
		})
	user_comments: (user_name, comments_sort, max_comments, after_comment_short_id) ->
		get("/user/#{user_name}/comments", {
			after: after_comment_short_id and "t1_#{after_comment_short_id}"
			limit: max_comments
			sort: comments_sort.split('-')[0]
			t: comments_sort.split('-')[1]
		})
	user_multireddits: (user_name) ->
		get("/api/multi/user/#{user_name}")
	user_posts: (user_name, posts_sort, max_posts, after_post_short_id) ->
		get("/user/#{user_name}/submitted", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			sort: posts_sort.split('-')[0]
			t: posts_sort.split('-')[1]
		})
	user_saved_comments: (user_name, comments_sort, max_comments, after_comment_short_id) ->
		get("/user/#{user_name}/saved", {
			after: after_comment_short_id and "t1_#{after_comment_short_id}"
			limit: max_comments
			sort: comments_sort.split('-')[0]
			t: comments_sort.split('-')[1]
			type: 'comments'
		})
	user_saved_posts: (user_name, posts_sort, max_posts, after_post_short_id) ->
		get("/user/#{user_name}/saved", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			sort: posts_sort.split('-')[0]
			t: posts_sort.split('-')[1]
			type: 'links'
		})
	wiki: (subreddit_name, page_name, version_short_id) ->
		get("/r/#{subreddit_name}/wiki/#{page_name}", {
			v: version_short_id
		})
	wiki_versions: (subreddit_name, page_name, max_versions, after_version_short_id) ->
		get("/r/#{subreddit_name}/wiki/revisions/#{page_name}", {
			after: after_wikipage_version_short_id and "WikiRevision_#{after_wikipage_version_short_id}"
			limit: max_versions
			show: 'all'
		})

}