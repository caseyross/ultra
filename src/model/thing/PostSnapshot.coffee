import Flair from '../wrapper/Flair'
import Image from '../wrapper/Image'
import Score from '../wrapper/Score'
import Video from '../wrapper/Video'

import ThingList from './ThingList'
import SubredditReference from './SubredditReference'
import UserReference from './UserReference'

export default class PostSnapshot
	constructor: (r) ->
		# BASIC DATA
		@author = new UserReference r.author
		@created_at = new Date(r.created_utc * 1000)
		@content = content(r)
		@distinguish = r.distinguished or 'original-poster'
		@edited_at = new Date(r.edited * 1000)
		@flairs =
			author: new Flair
				text: r.author_flair_text
				color: r.author_flair_background_color
			title: new Flair
				text: r.link_flair_text
				color: r.link_flair_background_color
		@id = r.id
		@permalink = r.permalink
		@subreddit = new SubredditReference r.subreddit
		# ACTIVITY
		@awards = [] # TODO
		@crossposts = r.crosspost_parent_list
		@score = new Score { value: r.score, hidden: r.hide_score }
		# COMMENTS
		@REPLIES =
			if r.replies?.length
				new LazyPromise -> Promise.resolve r.replies
			else if r.num_comments is 0
				new LazyPromise -> Promise.resolve []
			else
				new LazyPromise ->
					API.get 'comments/' + r.id,
						sort: r.suggested_sort
					.then ([ post_data, comments_data ]) ->
						new ThingList comments_data
		# STATES
		@archived = r.archived
		@contest = r.contest_mode
		@edited = r.edited
		@hid = r.hidden
		@liked = r.likes
		@locked = r.locked
		@nsfw = r.over_18
		@oc = r.is_original_content
		@pinned = r.pinned
		@quarantined = r.quarantine
		@saved = r.saved
		@spoiler = r.spoiler
		@stickied = r.stickied

content = (r) ->
	url = new URL(if r.url.startsWith 'http' then r.url else 'https://www.reddit.com' + r.url)
	title = r.title
	type = 'link'
	data = r.url
	DATA = new LazyPromise -> Promise.resolve null
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
			data = r.selftext
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
					DATA = new LazyPromise ->
						API.get 'comments/' + post_id,
							comment: comment_id
							context: 3
						.then ([ posts, comments ]) ->
							{
								...(new ThingList(posts))[0],
								REPLIES: new LazyPromise ->
									Promise.resolve new ThingList(comments)
							}
	return {
		title,
		type,
		data,
		DATA
	}