import { get, post } from '../../net/http.coffee'

export default {
	collection: (collection_short_id) ->
		get("/api/v1/collections/collection", {
			collection_id: collection_short_id
			include_links: true
		})
	current_user: ->
		get("/api/v1/me")
	current_user_messages: (max_messages, after_message_short_id) ->
		get("/message/inbox", {
			after: after_message_short_id and "t4_#{after_message_short_id}"
			limit: max_messages
			mark: false
			show: 'all'
		})
	current_user_multireddits_owned:  ->
		get("/api/multi/mine", {
			expand_srs: true
		})
	current_user_preferences: ->
		get("/api/v1/me/prefs")
	current_user_saved_comments: (user_name, comments_time_range, comments_sort, max_comments, after_comment_short_id) ->
		get("/user/#{user_name}/saved", {
			after: after_comment_short_id and "t1_#{after_comment_short_id}"
			limit: max_comments
			sort: comments_sort
			t: comments_time_range
			type: 'comments'
		})
	current_user_saved_posts: (user_name, posts_time_range, posts_sort, max_posts, after_post_short_id) ->
		get("/user/#{user_name}/saved", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			sort: posts_sort
			t: posts_time_range
			type: 'links'
		})
	current_user_subreddits_approved_to_submit: (max_subreddits) ->
		get("/subreddits/mine/contributor", {
			limit: max_subreddits
			show: 'all'
			sr_detail: true
		})
	current_user_subreddits_moderated: (max_subreddits) ->
		get("/subreddits/mine/moderator", {
			limit: max_subreddits
			show: 'all'
			sr_detail: true
		})
	current_user_subreddits_subscribed: (max_subreddits) ->
		get("/subreddits/mine/subscriber", {
			limit: max_subreddits
			show: 'all'
			sr_detail: true
		})
	comment: (comment_short_id) ->
		get("/api/info", {
			id: "t1_#{comment_short_id}"
		})
	global_subreddits_new: (max_subreddits) ->
		get("/subreddits/new", {
			limit: max_subreddits
			show: 'all'
			sr_detail: true
		})
	global_subreddits_popular: (max_subreddits) ->
		get("/subreddits/popular", {
			limit: Number(max_subreddits) + 1 # first result is always r/home
			show: 'all'
			sr_detail: true
		})
	multireddit: (user_name, multireddit_name) ->
		if user_name is 'r' then Promise.resolve({})
		else get("/api/multi/user/#{user_name}/m/#{multireddit_name}")
	multireddit_posts: (user_name, multireddit_name, posts_time_range, posts_sort, max_posts, after_post_short_id) ->
		get(
			switch
				when user_name is 'r' and multireddit_name is 'subscriptions' then "/#{posts_sort}"
				when user_name is 'r' then "/r/#{multireddit_name}/#{posts_sort}"
				else "/user/#{user_name}/m/#{multireddit_name}/#{posts_sort}"
			{
				after: after_post_short_id and "t3_#{after_post_short_id}"
				limit: max_posts
				show: 'all'
				sr_detail: true
				t: posts_time_range
			}
		)
	post: (post_short_id, comments_sort, max_comments, focus_comment_short_id, focus_comment_parent_count) ->
		get("/comments/#{post_short_id}", {
			comment: focus_comment_short_id
			context: focus_comment_parent_count
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
	post_more_replies: (post_short_id, post_comments_sort, post_max_comments, parent_comment_short_id, comment_short_ids) -> # NOTE: Max concurrency for this call is 1 per Reddit rules.
		post("/api/morechildren", {
			api_type: 'json'
			children: comment_short_ids
			link_id: "t3_#{post_short_id}"
			sort: post_comments_sort
		})
	search_posts: (query_string, posts_time_range, posts_sort, max_posts, after_post_short_id) ->
		path_prefix = ''
		if query_string.startsWith('multireddit=')
			[ multireddit_query_string, ...remaining_query ] = query_string.split('+')
			[ user_name, multireddit_name ] = multireddit_query_string.split('=')[1].split('-')
			path_prefix = "/user/#{user_name}/m/#{multireddit_name}"
			query_string = remaining_query.join('+')
		get("#{path_prefix}/search", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			q: query_string.replaceAll('+', ' ').replaceAll('=', ':') # max 512 chars
			restrict_sr: path_prefix.length > 0
			show: 'all'
			sort: posts_sort
			t: posts_time_range
		})
	search_subreddits: (search_text, max_subreddits) ->
		get("/subreddits/search", {
			limit: max_subreddits
			show: 'all'
			sort: 'relevance'
			q: search_text
		})
	search_subreddits_autocomplete: (search_text) ->
		get("/api/subreddit_autocomplete_v2", {
			include_over_18: true
			include_profiles: false
			limit: 10
			query: search_text # 1-25 chars
			typeahead_active: true
		})
	search_users: (search_text, max_users) ->
		get("/users/search", {
			limit: max_users
			show: 'all'
			sort: 'relevance'
			q: search_text
		})
	subreddit: (subreddit_name) ->
		get("/r/#{subreddit_name}/about")
	subreddit_emotes: (subreddit_name) ->
		get("/api/v1/#{subreddit_name}/emojis/all")
	subreddit_moderators: (subreddit_name, after_user_short_id) ->
		get("/r/#{subreddit_name}/about/moderators", {
			after: after_user_short_id and "t2_#{after_user_short_id}"
			limit: 100
			show: 'all'
		})
	subreddit_posts: (subreddit_name, posts_time_range, posts_sort, max_posts, after_post_short_id) ->
		get("/r/#{subreddit_name}/#{posts_sort}", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			show: 'all'
			t: posts_time_range
		})
	subreddit_post_flairs: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/link_flair_v2")
	subreddit_post_guidelines: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/submit_text")
	subreddit_post_requirements: (subreddit_name) ->
		get("/api/v1/#{subreddit_name}/post_requirements")
	subreddit_rules: (subreddit_name) ->
		get("/r/#{subreddit_name}/about/rules")
	subreddit_user_flairs: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/user_flair_v2")
	subreddit_widgets: (subreddit_name) ->
		get("/r/#{subreddit_name}/api/widgets", {
			progressive_images: true
		})
	user: (user_name) ->
		get("/user/#{user_name}/about", {
			sr_detail: true
		})
	users: (user_short_ids) ->
		get("/api/user_data_by_account_ids", {
			ids: user_short_ids.split(',').map((short_id) -> "t2_#{short_id}")
		})
	user_comments: (user_name, comments_time_range, comments_sort, max_comments, after_comment_short_id) ->
		get("/user/#{user_name}/comments", {
			after: after_comment_short_id and "t1_#{after_comment_short_id}"
			limit: max_comments
			sort: comments_sort
			t: comments_time_range
		})
	user_posts: (user_name, posts_time_range, posts_sort, max_posts, after_post_short_id) ->
		get("/user/#{user_name}/submitted", {
			after: after_post_short_id and "t3_#{after_post_short_id}"
			limit: max_posts
			sort: posts_sort
			t: posts_time_range
		})
	user_public_multireddits: (user_name) ->
		get("/api/multi/user/#{user_name}", {
			expand_srs: true
		})
	user_trophies: (user_name) ->
		get("/api/v1/user/username/trophies", {
			id: user_name
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