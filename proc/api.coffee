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
		post = rectified_posts(posts_listing)[0]
		{
			...post
			comments_fetch_time: Date.now()
			COMMENTS: new Promise (f, r) -> f rectified_comments comments_listing, post.subreddit_subscribers
		}

COMMENTS = ({ post_id, subreddit_subscribers }) ->
	GET 'comments/' + post_id
	.then ([ _, comments_listing ]) -> rectified_comments comments_listing, subreddit_subscribers

import { classify_post_content } from '/proc/post.coffee'

rectified_posts = (posts_listing) ->
	posts_listing.data.children.map (child) ->
		post = child.data
		# Setup for loading comments
		post.COMMENTS = new Promise (f, r) -> {}
		post.load_comments = () ->
			if not post.comments_fetch_time
				post.COMMENTS = COMMENTS { post_id: post.id, subreddit_subscribers: post.subreddit_subscribers }
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
		post.flair = post.link_flair_text ? ''
		post.flair_color = post.link_flair_background_color ? ''
		post.list_color = post.sr_detail.primary_color ? post.sr_detail.key_color ? 'inherit'
		post.is_sticky = post.stickied or post.pinned
		post

# Normalized length for HTML text containing arbitrary Unicode characters.
# The goal is to provide a metric for measuring textual information content that works for diverse languages, emojis, and other situations where String.length does not suffice.
# For English text, the score is approximately equal to the number of rendered characters in the text.
nl = (html_string) ->
	x = encodeURI(html_string.replace(/<[^>]+>/g, ''))
	return x.length - 2 * x.split('%').length

ns = (score, creation_time, subreddit_subscribers) ->
	x = score / subreddit_subscribers / (Date.now() / 1000 - creation_time)
	return 3600 * 1000000 * x

rectified_comments = (comments_listing, subreddit_subscribers) ->
	# No replies
	if not comments_listing?.data?.children then []
	# Ill-formed response structures
		# Very rare: empty array
	else if not comments_listing.data.children.length then []
		# Rare: "more" with 0 replies in it
	else if comments_listing.data.children[0].data.count is 0 then []
	# Replies, or "more"
	else comments_listing.data.children.map (child) ->
		comment = child.data
		if child.kind is 'more'
			comment.is_more = true
		else
			# Score.
			comment.score -= 1 # Don't count the built-in upvote from the commenter
			comment.ns = ns comment.score, comment.created_utc, subreddit_subscribers
			# Content.
			comment.body_html = comment.body_html[16...-6] # Trim useless (for us) tags
			comment.nl = nl comment.body_html
			# Replies.
			comment.is_more = false
			comment.replies = rectified_comments comment.replies, subreddit_subscribers
		return comment