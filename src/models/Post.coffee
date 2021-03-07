import Award from './Award'
import Comment from './Comment'
import Feed from './Feed'
import Flair from './Flair'
import Image from './Image'
import List from './List'
import User from './User'
import Video from './Video'

export default class Post
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
		@flair =
			if r.link_flair_text
				new Flair({
					text: r.link_flair_text,
					color: r.link_flair_background_color
				})
			else
				null
		@meta =
			author_relation: switch
				when r.distinguished
					r.distinguished
				else
					''
			archived: r.archived
			awards: r.all_awardings
			contest_mode: r.contest_mode
			crossposts:
				if r.crosspost_parent_list
					r.crosspost_parent_list.map((r) -> new Post(r))
				else
					[]
			edit_date:
				if r.edited
					new Date(r.edited * 1000)
				else
					null
			hidden: r.hidden
			hype: NaN # to be set by requester
			locked: r.locked
			native_feed: new Feed({ name: 'r/' + r.subreddit })
			nsfw: r.over_18
			oc: r.is_original_content
			quarantined: r.quarantine
			saved: r.saved
			score:
				if r.hide_score
					NaN
				else
					r.score
			spoiler: r.spoiler
			stickied: r.stickied or r.pinned
			submit_date: new Date(r.created_utc * 1000)

IFRAME_WIDTH = 960
IFRAME_HEIGHT = 540
class Content
	constructor: (r) ->
		@url = new URL(r.url)
		@type = 'link'
		@data = r.url
		switch
			when r.is_self
				@type = 'text'
				@data = r.selftext_html ? ''
			when r.post_hint is 'image'
				@type = 'image'
				@data =	[
					new Image(r.preview.images[0])
				]
			when r.is_gallery
				@type = 'image'
				@data = r.gallery_data.items.map((item) ->
					new Image({
						...r.media_metadata[item.media_id],
						caption: item.caption,
						link: item.outbound_url
					}))
			when r.post_hint is 'hosted:video'
				@type = 'video'
				@data = new Video(r.media.reddit_video)
			when r.domain.endsWith('reddit.com')
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
			else
				switch r.domain
					when 'gfycat.com'
						@type = 'iframe'
						@data =
							"""
							<iframe src='https://gfycat.com/ifr/#{@url.pathname.split('/')[1]}' allowfullscreen width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""
					when 'redgifs.com'
						@type = 'iframe'
						@data =
							"""
							<iframe src='https://redgifs.com/ifr/#{@url.pathname.split('/')[2]}' allowfullscreen width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""
					when 'clips.twitch.tv'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[1]}&parent=localhost" allowfullscreen width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""
					when 'twitch.tv'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://clips.twitch.tv/embed?clip=#{@url.pathname.split('/')[3]}&parent=localhost" allowfullscreen  width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""
					when 'youtube.com'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://www.youtube-nocookie.com/embed/#{@url.searchParams.get('v')}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""
					when 'youtu.be'
						@type = 'iframe'
						@data =
							"""
							<iframe src="https://www.youtube-nocookie.com/embed/#{@url.pathname.split('/')[1]}" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen width='#{IFRAME_WIDTH}' height='#{IFRAME_HEIGHT}'></iframe>
							"""

class Comments
	constructor: (r) ->
		@count = r.num_comments
		@sort = r.suggested_sort or 'default'
		@data = new LazyPromise(=>
			comments = new List(r.replies)
			if comments.length
				# we already have the comments.
				calc_hype(comments)
				Promise.resolve(comments)
			else if @count is 0
				# no comments on this post.
				Promise.resolve(new List([]))
			else
				# we don't have the comments yet. get them.
				Server.get({
					endpoint: '/comments/' + r.id
					options:
						comment: r.comment_id
						context: r.comment_context
				}).then ([ _, comment_listing ]) ->
					comments = new List(comment_listing)
					calc_hype(comments)
					comments
		)
calc_hype = (comments) ->
	now = Date.now()
	log_score_per_hour = (comment) =>
		if Number.isFinite(comment.meta.score)
			Math.log(comment.meta.score / ((now - comment.meta.submit_date.valueOf()) / 3600000))
		else
			NaN
	# calc distribution
	values = []
	add_subtree_values = (comment) ->
		if comment instanceof Comment
			values.push(log_score_per_hour(comment))
			for reply in comment.replies
				add_subtree_values(reply)
	for comment in comments
		add_subtree_values(comment)
	distribution = new NormalDistribution(values.filter((x) -> Number.isFinite(x)))
	# calc and set each comment's hype
	set_subtree_deviation = (comment) ->
		if comment instanceof Comment
			comment.meta.hype = distribution.deviation(log_score_per_hour(comment))
			for reply in comment.replies
				set_subtree_deviation(reply)
	for comment in comments
		set_subtree_deviation(comment)