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

post = (r) ->
	# BASIC DATA
	author: r.author
	created_at: new Date(r.created_utc * 1000)
	content: content(r)
	distinguish: r.distinguished or 'original-poster'
	edited_at: new Date(r.edited * 1000)
	flairs:
		author: new Flair
			text: r.author_flair_text
			color: r.author_flair_background_color
		title: new Flair
			text: r.link_flair_text
			color: r.link_flair_background_color
	href: '/r/' + r.subreddit + '/post/' + r.id
	subreddit: r.subreddit
	title: r.title
	# ACTIVITY
	awards: [] # TODO
	crossposts: r.crosspost_parent_list
	score: new Score { value: r.score, hidden: r.hide_score }
	# STATES
	archived: r.archived
	contest: r.contest_mode
	edited: r.edited
	hidden: r.hidden
	liked: r.likes
	locked: r.locked
	nsfw: r.over_18
	oc: r.is_original_content
	pinned: r.pinned
	quarantined: r.quarantine
	saved: r.saved
	spoiler: r.spoiler
	stickied: r.stickied

content = (r) ->
	type = 'link'
	data = r.url
	url = new URL(if r.url.startsWith 'http' then r.url else 'https://www.reddit.com' + r.url)
	switch
		when r.media?.reddit_video
			type = 'video'
			data = new Video(r.media.reddit_video)
		when r.is_gallery
			type = 'image'
			data = r.gallery_data.items.map (item) ->
				new Image { ...r.media_metadata[item.media_id], caption: item.caption, link: item.outbound_url }
		when r.post_hint is 'image'
			type = 'image'
			data =	[ new Image(r.preview.images[0]) ]
		when r.is_self
			type = 'text'
			data = r.selftext_html
		else switch r.domain
			when 'i.redd.it'
				type = 'image'
				data = [ new Image { p: [], s: [{ u: r.url }] } ]
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