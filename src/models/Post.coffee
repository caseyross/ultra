import Award from './Award'
import Distinguish from './Distinguish'
import Feed from './Feed'
import Flair from './Flair'
import Image from './Image'
import List from './List'
import User from './User'
import Video from './Video'

export default class 
	constructor: (r) ->
		@id = r.id
		@title = r.title
		@author = new User({
			name: r.author
			flair: new Flair({
				text: r.author_flair_text,
				color: r.author_flair_background_color
			})
		})
		@content = new Content(
			if r.crosspost_parent_list
				r.crosspost_parent_list[0]
			else
				r
		)
		@comments = new Comments(r)
		@flair = new Flair({
			text: r.link_flair_text,
			color: r.link_flair_background_color
		})
		@meta =
			awards:
				list: r.all_awardings.map((a) -> new Award(a))
				spend: r.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
			archived: r.archived
			contest_mode: r.contest_mode
			crossposts:
				if r.crosspost_parent_list
					r.crosspost_parent_list.map((p) -> new this(p)) #TODO: fix
				else
					[]
			distinguish: new Distinguish({
				naive_type: r.distinguished,
				is_op: true
			})
			edit_date:
				if r.edited
					new Date(r.edited * 1000)
				else
					null
			hidden: r.hidden
			locked: r.locked
			native_feed: new Feed({ name: 'r/' + r.subreddit })
			nsfw: r.over_18
			oc: r.is_original_content
			quarantined: r.quarantine
			saved: r.saved
			score:
				if r.hide_score
					'score hidden'
				else
					r.score - 1
			spoiler: r.spoiler
			stickied: r.stickied or r.pinned
			submit_date: new Date(r.created_utc * 1000)

class Content
	constructor: (r) ->
		@url = new URL(r.url)
		@type = 'link'
		@data = r.url
		switch
			when r.is_self
				@type = 'text'
				@data = r.selftext ? ''
			when r.post_hint is 'image' or r.is_gallery
				@type = 'image'
				@data =
					if r.is_gallery
						r.gallery_data.items.map((item) ->
							new Image({
								...r.media_metadata[item.media_id],
								caption: item.caption,
								link: item.outbound_url
							}))
					else
						[
							new Image(r.preview.images[0])
						]
			when r.post_hint is 'hosted:video' or r.rpan_video
				#TODO
			else
				switch r.domain
					when 'reddit.com', 'np.reddit.com', 'old.reddit.com', 'new.reddit.com'
						[ _, domain, subdomain, sort, post_id, _, comment_id ] = @url.pathname.split('/')
						if sort is 'comments'
							if comment_id
								@type = 'comment'
								@data = new Comments({
									id: post_id,
									comment_id: comment_id,
									comment_context: @url.searchParams.get('context')
								})
							else if post_id
								@type = 'link'
								#TODO (treat as link, mostly)
						else if subdomain
							@type = 'feed'
							@data = new Feed({ url: @url })
					when 'gfycat.com'
						@type = 'iframe'
						@data =
							"""
							<iframe src='https://gfycat.com/ifr/#{@url.pathname.split('/')[1]}' allowfullscreen width='640' height='640'></iframe>
							"""
					when 'redgifs.com'
						@type = 'iframe'
						@data =
							"""
							<iframe src='https://redgifs.com/ifr/#{@url.pathname.split('/')[2]}' allowfullscreen width='640' height='640'></iframe>
							"""
					when 'clips.twitch.tv'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[1]}&parent=localhost" allowfullscreen="true" height="360" width="640"></iframe>
							"""
					when 'twitch.tv'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[3]}&parent=localhost" allowfullscreen="true" height="360" width="640"></iframe>
							"""
					when 'youtube.com'
						@type = 'iframe'
						@data =
							"""
							<iframe width="640" height="360" src="https://www.youtube-nocookie.com/embed/#{@url.searchParams.get('v')}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
							"""
					when 'youtu.be'
						@type = 'iframe'
						@data =
							"""
							<iframe width="640" height="360" src="https://www.youtube-nocookie.com/embed/#{@url.pathname.split('/')[1]}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
							"""

class Comments
	constructor: (r) ->
		@suggested_sort = r.suggested_sort
		@count = r.num_comments
		@data = new LazyPromise(=>
			provided = new List(r.replies)
			if provided.length
				# we already have the comments.
				Promise.resolve provided
			else if @count is 0
				# no comments on this post.
				Promise.resolve []
			else
				# we don't have the comments yet. get them.
				Server.get({
					endpoint: '/comments/' + r.id
					options:
						comment: r.comment_id
						context: r.comment_context
				}).then ([ _, comment_listing ]) -> new List(comment_listing)
		)