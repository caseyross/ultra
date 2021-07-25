import Image from '../../media/Image.coffee'
import Video from '../../media/Video.coffee'

export default class PostContent

	constructor: (data) ->

		@type = 'link'
		@href = data.url
		switch
			when data.media?.reddit_video
				@type = 'video'
				@video = new Video(data.media.reddit_video)
			when data.is_gallery
				@type = 'image'
				@images = data.gallery_data.items.map (x) ->
					new Image { ...data.media_metadata[x.media_id], caption: x.caption, link: x.outbound_url }
			when data.post_hint is 'image'
				@type = 'image'
				@images = [ new Image(data.preview.images[0]) ]
			when data.is_self
				@type = 'self'
				@selftext = data.selftext_html
			else
				u = new URL(if data.url.startsWith 'https' then data.url else 'https://www.reddit.com' + data.url)
				switch data.domain
					when 'i.redd.it'
						@type = 'image'
						@images = [ new Image { p: [], s: [{ u: data.url }] } ]
					when 'gfycat.com'
						@type = 'embed'
						@src = "https://gfycat.com/ifr/#{u.pathname.split('/')[1]}"
					when 'redgifs.com'
						@type = 'embed'
						@src = "https://redgifs.com/ifr/#{u.pathname.split('/')[2]}"
					when 'clips.twitch.tv'
						@type = 'embed'
						@src = "https://clips.twitch.tv/embed?clip=#{u.pathname.split('/')[1]}&parent=localhost"
					when 'twitch.tv'
						@type = 'embed'
						@src = "https://clips.twitch.tv/embed?clip=#{u.pathname.split('/')[3]}&parent=localhost"
					when 'youtube.com'
						unless u.pathname.split('/')[1] is 'clip' # clip URLs don't contain the information necessary for embedding
							@type = 'embed'
							@src = "https://www.youtube-nocookie.com/embed/#{u.searchParams.get('v')}"
							@allow = 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
					when 'youtu.be'
						@type = 'embed'
						@src = "https://www.youtube-nocookie.com/embed/#{u.pathname.split('/')[1]}"
						@allow = 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
					when 'reddit.com', 'np.reddit.com', 'old.reddit.com', 'new.reddit.com'
						[ _, _, _, _, post_id, _, comment_id ] = u.pathname.split('/')
						@type = 'reddit'
						@post_id = post_id
						@comment_id = comment_id