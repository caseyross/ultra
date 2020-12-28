import RedditFlair from '/objects/RedditFlair'
import RedditImage from '/objects/RedditImage'
import RedditItems from '/objects/RedditItems'

export default class RedditPost
	constructor: (raw) ->
		@author =
			name: raw.author
			premium: raw.author_premium
		@awards =
			list: []
			spend: raw.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
		@comments =
			count: raw.num_comments
			defaultSort: raw.suggested_sort ? ''
			list: new RedditItems(raw.replies)
		@content = parseContent(raw.crosspost_parent_list?[0] ? raw)
		@crossposts =
			count: raw.num_crossposts
			parentId: raw.crosspost_parent_list?[0]?.id ? ''
		@flags =
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
		@flairs =
			author: new RedditFlair(raw.author_flair_text, raw.author_flair_background_color)
			title: new RedditFlair(raw.link_flair_text, raw.link_flair_background_color)
		@id = raw.id
		@listingId = raw.subreddit_name_prefixed.toLowerCase()
		@permalink = '/' + @listingId + '/' + @id
		@stats =
			ratio: raw.upvote_ratio
			score: raw.score - 1
		@title = raw.title
		@times =
			edit: raw.edited or NaN
			parse: Date.now() // 1000
			submit: raw.created_utc

parseContent = (raw) ->
	content =
		embeds: []
		images: []
		link: ''
		text: ''
		type: 'unknown'
		videos: []
	switch
		when raw.is_self
			content.type = 'text'
			content.text = raw.selftext_html?[31...-20] ? ''
		when raw.post_hint is 'image' or raw.is_gallery
			content.type = 'image'
			if raw.is_gallery
				content.images = raw.gallery_data.items.map((item) -> new RedditImage(raw.media_metadata[item.media_id]))
			else
				content.images = [new RedditImage(raw.preview.images[0])]
		when raw.post_hint is 'hosted:video' or raw.rpan_video
			content.type = 'video'
			content.videos = []
		when raw.post_hint is 'rich:video'
			content.type = 'embed'
			content.embeds = []
		when raw.domain.endsWith('reddit.com')
			content.type = 'comment'
			[ _, _, _, _, _, _, postId, _, commentId, queryParameters ] = raw.url.split('/')
			content.POST = Reddit.POST {
				id: postId,
				commentId: commentId,
				commentContext: (new URLSearchParams(queryParameters)).get('context')
			}
		when raw.post_hint is 'link'
			content.type = 'link'
			content.link = raw.url
	return content