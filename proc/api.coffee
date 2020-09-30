# docs: https://github.com/reddit-archive/reddit/wiki/OAuth2#application-only-oauth
# docs: https://www.reddit.com/dev/api

REFRESH_TOKEN = () ->
	fetch 'https://www.reddit.com/api/v1/access_token',
		method: 'POST'
		headers:
			'Authorization': 'Basic SjZVcUg0a1lRTkFFVWc6'
		body: new URLSearchParams
			grant_type: 'https://oauth.reddit.com/grants/installed_client'
			device_id: 'DO_NOT_TRACK_THIS_DEVICE'
	.then (response) -> response.json()
	.then (json) ->
		ls.api_token_type = json.token_type
		ls.api_token_value = json.access_token
		ls.api_token_expire_time = Date.now() + json.expires_in * 999

GET = (endpoint, options = {}) ->
	if endpoint is null then return new Promise (f, r) -> f({})
	# If access token is absent or already expired, block while getting a new one.
	# If access token is expiring soon, don't block the current operation, but pre-emptively request a new token.
	if not ls.api_token_expire_time or Date.now() > ls.api_token_expire_time then await REFRESH_TOKEN()
	else if Date.now() > ls.api_token_expire_time - 600000 then REFRESH_TOKEN()
	# Finalize options; remove those with empty string as a value.
	options.raw_json = 1
	for name, value of options
		if value is '' then delete options[name]
	fetch 'https://oauth.reddit.com/' + endpoint + '?' + (new URLSearchParams(options)).toString(),
		method: 'GET'
		headers:
			'Authorization': ls.api_token_type + ' ' + ls.api_token_value
	.then (response) -> response.json()

export LIST = ({ id, page_size, predecessor_object_id, rank_by, time_period }) ->
	GET (switch id[0]
			when 'u' then 'user/' + id[2..]
			when 'r' then id + '/' + rank_by
			else rank_by),
		t: if rank_by is 'top' or rank_by is 'controversial' then time_period else ''
		sort: if id[0] is 'u' then rank_by else ''
		limit: page_size
		after: predecessor_object_id
		sr_detail: true
	.then (posts_listing) -> rectified_posts posts_listing

export LIST_DESCRIPTION = ({ id }) ->
	GET switch id[0]
			when 'u' then 'user/' + id[2..] + '/about'
			when 'r' then id + '/about'
			else null
	.then ({ data }) ->
		{
			...data
			description_html: if data?.description_html then data.description_html[31...-20] else ''
		}

export POST_AND_COMMENTS = ({ id, comroot_id, comroot_parent_count }) ->
	GET 'comments/' + id,
		comment: comroot_id
		context: if comroot_parent_count > 0 then comroot_parent_count else ''
	.then ([ posts_listing, comments_listing ]) ->
		{
			...rectified_posts(posts_listing)[0]
			comments_fetch_time: Date.now()
			COMMENTS: new Promise (f, r) -> f rectified_comments comments_listing
		}

COMMENTS = ({ post_id }) ->
	GET 'comments/' + post_id
	.then ([ _, comments_listing ]) -> rectified_comments comments_listing

import { classify_post_content } from '/proc/post.coffee'
import { reltime } from '/proc/time.coffee'

rectified_posts = (posts_listing) ->
	posts_listing.data.children.map (child) ->
		post = child.data
		# Setup for loading comments
		post.COMMENTS = new Promise (f, r) -> {}
		post.load_comments = () ->
			if not post.comments_fetch_time
				post.COMMENTS = COMMENTS { post_id: post.id }
				post.comments_fetch_time = Math.trunc(Date.now() / 1000)
		# Identify content of post
		if post.crosspost_parent
			post.is_xpost = true
			post.xpost_from = post.crosspost_parent_list[0].subreddit
			post.content = classify_post_content post.crosspost_parent_list[0]
		else
			post.is_xpost = false
			post.content = classify_post_content post
		# Rewrite HTTP URLs to use HTTPS
		if post.content.url?.startsWith 'http://' then post.content.url = 'https://' + post.content.url[7..]
		# Standardize properties
		post.age = reltime(Date.now() / 1000 - post.created_utc)
		post.flair = post.link_flair_text ? ''
		post.flair_color = post.link_flair_background_color ? ''
		post.list_color = post.sr_detail.primary_color ? post.sr_detail.key_color ? 'inherit'
		post.is_sticky = post.stickied or post.pinned
		post

rectified_comments = (comments_listing) ->
	post_skeleton =
		body: ''
		replies: restructured_comments comments_listing
		score_per_hour: 0
	comment_tree_character_count = (comment) -> comment.body.length + comment.replies.reduce(((sum, reply) -> sum + comment_tree_character_count reply), 0)
	comment_tree_score_per_hour = (comment) -> Math.abs comment.score_per_hour + comment.replies.reduce(((sum, reply) -> sum + comment_tree_score_per_hour reply), 0)
	total_character_count = comment_tree_character_count post_skeleton
	total_score_per_hour = comment_tree_score_per_hour post_skeleton
	estimate_interest = (comment) ->
		comment.character_count_percentage = Math.trunc(comment.body.length / total_character_count * 100)
		comment.score_per_hour_percentage = Math.trunc(comment.score_per_hour / total_score_per_hour * 100)
		comment.estimated_interest = if comment.score_hidden then 2 else comment.score_per_hour_percentage + comment.character_count_percentage
		estimate_interest reply for reply in comment.replies
	estimate_interest post_skeleton
	post_skeleton.replies

restructured_comments = (comments_listing) ->
	# No replies
	if not comments_listing?.data?.children then []
	# Ill-formed response structures
		# Very rare: empty array
	else if not comments_listing.data.children.length then []
		# Rare: "more" with 0 replies in it
	else if comments_listing.data.children[0].data.count is 0 then []
	# Replies, or "more"
	else comments_listing.data.children.map (child) ->
		if child.kind is 'more'
			{
				...child.data
				body: ''
				is_more: true
				replies: []
				score_per_hour: 0
			}
		else
			{
				...child.data
				body_html: child.data.body_html[16...-6]
				is_more: false
				replies: restructured_comments child.data.replies
				score: child.data.score - 1 # Don't count the built-in upvote from the commenter
				score_per_hour: (child.data.score - 1) * 3600 / (Date.now() / 1000 - child.data.created_utc)
			}