import Comments from './Comments'
import Flair from './Flair'
import Image from './Image'
import Score from './Score'
import Video from './Video'

export default class Post
	constructor: ({ id, comment_id, data }) ->
		if data
			@pinned = data.pinned # duplicated for feed item display
			@stickied = data.stickied # duplicated for feed item display
			@href = '/r/' + data.subreddit + '/post/' + data.id # duplicated for feed item display
			@score = new Score { value: data.score, hidden: data.hide_score } # duplicated for feed item display
			@id = data.id
			@comment_id = data.comment_id
			@POST = new LazyPromise -> Promise.resolve post data
			@COMMENTS = new LazyPromise ->
				if data.num_comments is 0
					Promise.resolve []
				else
					API.get 'comments/' + data.id,
						comment: data.comment_id
						context: if data.comment_id then 3 else ''
						sort: data.suggested_sort # TODO: check effect
					.then ([ posts, comments ]) ->
						new Comments comments
		else
			@id = id
			@comment_id = comment_id
			promise =
				API.get 'comments/' + id,
					comment: comment_id
					context: if comment_id then 3 else ''
				.then ([ posts, comments ]) ->
					[
						post posts.data.children[0].data
						new Comments comments
					]
			@POST = new LazyPromise -> promise.then (result) -> result[0]
			@COMMENTS = new LazyPromise -> promise.then (result) -> result[1]

post = (d) ->
	# BASIC DATA
	author: d.author
	created_at: new Date(d.created_utc * 1000)
	content: content(d)
	distinguish: d.distinguished or 'original-poster'
	edited_at: new Date(d.edited * 1000)
	flairs:
		author: new Flair
			text: d.author_flair_text
			color: d.author_flair_background_color
		title: new Flair
			text: d.link_flair_text
			color: d.link_flair_background_color
	href: '/r/' + d.subreddit + '/post/' + d.id
	subreddit: d.subreddit
	title: d.title
	xpost_parent:
		if d.crosspost_parent_list
			new Post(d.crosspost_parent_list[0])
		else
			null
	# ACTIVITY
	awards: [] # TODO
	score: new Score { value: d.score, hidden: d.hide_score }
	# STATES
	archived: d.archived
	contest: d.contest_mode
	edited: d.edited
	hidden: d.hidden
	liked: d.likes
	locked: d.locked
	nsfw: d.over_18
	oc: d.is_original_content
	pinned: d.pinned
	quarantined: d.quarantine
	saved: d.saved
	spoiler: d.spoiler
	stickied: d.stickied

content = (d) ->
	type = 'link'
	data = d.url
	url = new URL(if d.url.startsWith 'http' then d.url else 'https://www.reddit.com' + d.url)
	switch
		when d.media?.reddit_video
			type = 'video'
			data = new Video(d.media.reddit_video)
		when d.is_gallery
			type = 'image'
			data = d.gallery_data.items.map (item) ->
				new Image { ...d.media_metadata[item.media_id], caption: item.caption, link: item.outbound_url }
		when d.post_hint is 'image'
			type = 'image'
			data =	[ new Image(d.preview.images[0]) ]
		when d.is_self
			type = 'text'
			data = d.selftext_html
		else switch d.domain
			when 'i.redd.it'
				type = 'image'
				data = [ new Image { p: [], s: [{ u: d.url }] } ]
			when 'gfycat.com'
				type = 'iframe'
				data =
					src: "https://gfycat.com/ifr/#{url.pathname.split('/')[1]}"
			when 'redgifs.com'
				type = 'iframe'
				data =
					src: "https://redgifs.com/ifr/#{url.pathname.split('/')[2]}"
			when 'clips.twitch.tv'
				type = 'iframe'
				data =
					src: "https://clips.twitch.tv/embed?clip=#{url.pathname.split('/')[1]}&parent=localhost"
			when 'twitch.tv'
				type = 'iframe'
				data =
					src: "https://clips.twitch.tv/embed?clip=#{url.pathname.split('/')[3]}&parent=localhost"
			when 'youtube.com'
				unless url.pathname.split('/')[1] is 'clip' # clip URLs don't contain the information necessary for embedding
					type = 'iframe'
					data =
						src: "https://www.youtube-nocookie.com/embed/#{url.searchParams.get('v')}"
						allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
			when 'youtu.be'
				type = 'iframe'
				data =
					src: "https://www.youtube-nocookie.com/embed/#{url.pathname.split('/')[1]}"
					allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
			when 'reddit.com', 'np.reddit.com', 'old.reddit.com', 'new.reddit.com'
				[ _, _, _, _, post_id, _, comment_id ] = url.pathname.split('/')
				if comment_id
					type = 'comment'
					data = new Post { id: post_id, comment_id: comment_id }
				else if post_id
					type = 'post'
					data = new Post { id: post_id }
	return {
		type,
		data
	}