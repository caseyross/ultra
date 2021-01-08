import RedditFeed from '/objects/RedditFeed'
import RedditFlair from '/objects/RedditFlair'
import RedditImage from '/objects/RedditImage'
import RedditList from '/objects/RedditList'
import RedditUser from '/objects/RedditUser'

export default class RedditPost
	constructor: (raw) ->
		if typeof raw is 'string' and raw.length
			# No data provided, only the ID.
			postId = raw.match(/p[A-Z0-9]+/)
			commentFocusId = raw.match(/c[A-Z0-9]+/)
			commentFocusDepth = raw.match(/d[A-Z0-9]+/)
			@id = postId
			@data =
				Api.get '/comments/' + id[1..].toLowerCase(),
					comment: commentFocusId[1..].toLowerCase()
					context: commentFocusDepth[1..] ? 3
				.then ([ rawPostListing, rawCommentListing ]) ->
					[ rawPost ] = new RedditList(rawPostListing)
					return parse({ ...rawPost, replies: rawCommentListing })
		else
			# (At least some) data provided.
			@id = 'p' + raw.id.toUpperCase()
			@data = Promise.resolve(parse(raw))

parse = (raw) ->
	author: new RedditUser(raw.author)
	awards:
		list: raw.all_awardings
		spend: raw.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
	comments: parseComments(raw)
	content: parseContent(raw)
	flags:
		archived: raw.archived
		contest: raw.contest_mode
		edited: raw.edited?
		hidden: raw.hidden
		locked: raw.locked
		nsfw: raw.over_18
		oc: raw.is_original_content
		quarantined: raw.quarantine
		saved: raw.saved
		scoreHidden: raw.hide_score
		spoiler: raw.spoiler
		stickied: raw.stickied or raw.pinned
	flairs:
		author: new RedditFlair(raw.author_flair_text, raw.author_flair_background_color)
		title: new RedditFlair(raw.link_flair_text, raw.link_flair_background_color)
	nativeFeed: new RedditFeed(raw.subreddit_name_prefixed)
	ratio: raw.upvote_ratio
	score: raw.score - 1
	title: raw.title
	times:
		edit: raw.edited or NaN
		parse: Date.now() // 1000
		submit: raw.created_utc
	xposts:
		count: raw.num_crossposts
		parentId: if raw.crosspost_parent_list?[0] then 'p' + raw.crosspost_parent_list[0].id.toUpperCase() else null

parseComments = (raw) ->
	commentsProvided = new RedditList(raw.replies)
	if commentsProvided.length
		# We already have the comments.
		Promise.resolve(commentsProvided)
	else if raw.num_comments > 0
		# We don't have the comments yet.
		Api.get('/comments/' + raw.id)
		.then ([ _, rawCommentListing ]) -> new RedditList(rawCommentListing)
	else
		# There aren't any comments on this post.
		Promise.resolve([])

parseContent = (raw) ->
	if raw.crosspost_parent_list
		return parseContent(raw.crosspost_parent_list[0])
	content =
		embeds: []
		images: []
		link: ''
		post: null
		text: ''
		type: 'unknown'
		videos: []
	switch
		when raw.is_self
			content.type = 'text'
			content.text = raw.selftext_html?[31...-20] ? ''
		when raw.post_hint is 'image' or raw.is_gallery
			content.type = 'image'
			content.images =
				if raw.is_gallery
					raw.gallery_data.items.map((item) -> new RedditImage(raw.media_metadata[item.media_id]))
				else
					[new RedditImage(raw.preview.images[0])]
		when raw.post_hint is 'hosted:video' or raw.rpan_video
			content.type = 'video'
			content.videos = []
		when raw.post_hint is 'rich:video'
			content.type = 'embed'
			content.embeds = []
		when raw.domain.endsWith('reddit.com')
			content.type = 'comment'
			[ _, _, _, _, _, _, postId, _, commentFocusId, query ] = raw.url.split('/')
			content.post = new RedditPost("p#{postId.toUpperCase()}c#{commentFocusId.toUpperCase()}d#{(new URLSearchParams(query)).get('context')}")
		when raw.post_hint is 'link'
			content.type = 'link'
			content.link = raw.url
	return content