import { Award, Flair, Score, Subreddit } from '../'
import ModeledArray from '../ModeledArray'
import Image from './Image'
import Video from './Video'

export default class Post
	constructor: ({ id = '', data = null }) ->
		if id
			# Only have the ID so far.
			@id = id
			fetch_post = API.get('/comments/' + id[2..])
			@INFO = new LazyPromise => fetch_post.then ([ post_data, comments_data ]) -> new PostInfo(post_data)
			@CONTENT = new LazyPromise => fetch_post.then ([ post_data, comments_data ]) ->
				# If link is to another Reddit comment, fetch that comment.
				url = new URL post_data.url
				if url.host.endsWith('reddit.com')
					[ _, _, _, _, post_number, _, comment_number ] = url.pathname.split('/')
					if comment_number
						API.get '/comments/' + post_number,
							comment: comment_number
							context: url.searchParams.get('context')
						.then ([ post_data, comments_data ]) -> new PostContent { ...post_data, is_comment: true, comments_data }
				# Else...
				return PostContent(data)
			@COMMENTS = new LazyPromise => fetch_post.then ([ post_data, comments_data ]) -> new PostComments(post_data)
		else if data
			# Have the post data, just not the comments.
			@id = 't3_' + data.id
			@INFO = new LazyPromise => Promise.resolve new PostInfo(data)
			@CONTENT = new LazyPromise =>
				# If link is to another Reddit comment, fetch that comment.
				url = new URL data.url
				if url.host.endsWith('reddit.com')
					[ _, _, _, _, post_number, _, comment_number ] = url.pathname.split('/')
					if comment_number
						API.get '/comments/' + post_number,
							comment: comment_number
							context: url.searchParams.get('context')
						.then ([ post_data, comments_data ]) -> new PostContent { ...data, is_comment: true, comments_data }
				# Else...
				return Promise.resolve new PostContent(data)
			@COMMENTS = new LazyPromise =>
				if data.num_comments is 0
					Promise.resolve new PostComments([])
				else
					API.get('/comments/' + data.id, { sort: data.suggested_sort or 'confidence' })
					.then ([ post_data, comments_data ]) ->	new PostComments(comments_data)
		else
			throw new Error()

class PostInfo
	constructor: (r) ->
		@author =
			flair: new Flair { text: r.author_flair_text, color: r.author_flair_background_color }
			name: r.author
			relation: r.distinguished or 'submitter'
		@edit_date = if r.edited then new Date(r.edited * 1000) else null
		@engagement =
			awards: r.all_awardings.map((x) -> new Award(x))
			crossposts: if r.crosspost_parent_list then r.crosspost_parent_list.map (r) -> new Post { data: r } else []
			score: new Score { value: r.score, hidden: r.hide_score }
		@tags =
			archived: r.archived
			contest_mode: r.contest_mode
			hidden: r.hidden
			locked: r.locked
			not_safe_for_work: r.over_18
			original_content: r.is_original_content
			quarantined: r.quarantine
			saved: r.saved
			spoiler: r.spoiler
			stickied: r.stickied or r.pinned
		@title =
			flair: if r.link_flair_text then new Flair { text: r.link_flair_text, color: r.link_flair_background_color } else null
			text: r.title
		@submit_date = new Date(r.created_utc * 1000)
		@subreddit = new Subreddit { name: r.subreddit }

class PostContent
	constructor: (r) ->
		@url = new URL(r.url)
		@type = 'link'
		@data = r.url
		switch
			when r.is_comment
				@type = 'comment'
				@data = new PostComments(r.comments_data)
			when r.media?.reddit_video
				@type = 'video'
				@data = new Video(r.media.reddit_video)
			when r.is_gallery
				@type = 'image'
				@data = r.gallery_data.items.map (item) ->
					new Image { ...r.media_metadata[item.media_id], caption: item.caption, link: item.outbound_url }
			when r.post_hint is 'image'
				@type = 'image'
				@data =	[ new Image(r.preview.images[0]) ]
			when r.is_self
				@type = 'text'
				@data = r.selftext_html ? ''
			else
				switch r.domain
					when 'i.redd.it'
						@type = 'image'
						@data = [ new Image { p: [], s: [{ u: r.url }] } ]
					when 'gfycat.com'
						@type = 'iframe'
						@data =
							src: "https://gfycat.com/ifr/#{@url.pathname.split('/')[1]}"
					when 'redgifs.com'
						@type = 'iframe'
						@data =
							src: "https://redgifs.com/ifr/#{@url.pathname.split('/')[2]}"
					when 'clips.twitch.tv'
						@type = 'iframe'
						@data =
							src: "https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[1]}&parent=localhost"
					when 'twitch.tv'
						@type = 'iframe'
						@data =
							src: "https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[3]}&parent=localhost"
					when 'youtube.com'
						unless @url.pathname.split('/')[1] is 'clip' # clip URLs don't contain the information necessary for embedding
							@type = 'iframe'
							@data =
							src: "https://www.youtube-nocookie.com/embed/#{@url.searchParams.get('v')}"
							allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
					when 'youtu.be'
						@type = 'iframe'
						@data =
							src: "https://www.youtube-nocookie.com/embed/#{@url.pathname.split('/')[1]}"
							allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'

class PostComments
	constructor: (r) -> return new ModeledArray(r)