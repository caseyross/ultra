import { API_GET } from '/proc/api_primitives.coffee'
import gfycat_adjectives from '/data/gfycat-adjectives.json'
import gfycat_animals from '/data/gfycat-animals.json'

# Docs: https://www.reddit.com/dev/api

export SMRPAGE = ({ type, name, range, sort, follow_id, max_count }) ->
	endpoint = switch
		when type is 'r'
			"/r/#{name}/#{sort}"
		when type is 'sm'
			switch name
				when '0/all'
					"/r/all/#{sort}"
				when '0/popular'
					"/r/popular/#{sort}"
				else
					"/#{sort}"
	API_GET endpoint,
		t: if sort is 'top' or sort is 'controversial' then range else ''
		sort: sort
		after: follow_id
		limit: max_count
		sr_detail: true
	.then (listing) ->
		listing.data.children.map (child) ->
			post = regularize_post child.data
			post.COMMENTS = new Promise () -> {}
			post.sync_comments = () ->
				post.COMMENTS = SINGLEPOST { id: post.id, comments_only: true }
				post.comments_sync_time = Math.trunc(Date.now() / 1000)
			return post
			
export USERPAGE = ({ name, range, sort, follow_id, max_count }) ->
	API_GET "/user/#{name}",
		t: if sort is 'top' or sort is 'controversial' then range else ''
		sort: sort
		after: follow_id
		limit: max_count
		sr_detail: true
	.then (listing) ->
		listing.data.children.map (child) ->
			console.log child.data

export SRABOUT = ({ name }) ->
	API_GET "/r/#{name}/about"
	.then ({ data }) -> data

export USERABOUT = ({ name }) ->
	API_GET "/user/#{name}/about"
	.then ({ data }) -> data

export SINGLEPOST = ({ id, comments_root_id, comments_root_parents, comments_only = false }) ->
	API_GET "/comments/#{id}",
		comment: comments_root_id
		context: comments_root_parents
	.then ([ posts_listing, comments_listing ]) ->
		post = regularize_post posts_listing.data.children[0].data
		post.COMMENTS = regularize_comments_listing comments_listing
		return if comments_only then post.COMMENTS else post

regularize_post = (post) ->
	post.is_xpost = post.crosspost_parent
	if post.is_xpost
		post.xpost_from = post.crosspost_parent_list[0].subreddit
	post.content = classify_post_content(if post.is_xpost then post.crosspost_parent_list[0] else post)
	if post.content.url?.startsWith 'http://'
		post.content.url = "https://#{post.content.url[7..]}"
	post.is_sticky = post.stickied or post.pinned
	post.flair = post.link_flair_text ? ''
	post.flair_color = post.link_flair_background_color ? ''
	post.sr_color = post.sr_detail?.primary_color ? post.sr_detail?.key_color ? 'inherit'
	return post

classify_post_content = (post) ->
	if post.is_meta
		# Reddit TODO
		return {
			type: 'meta'
		}
	if post.is_self
		if post.selftext_html
			return {
				type: 'html'
				html: post.selftext_html[31...-20]
			}
		return {
			type: 'empty'
		}
	if post.is_gallery
		return {
			type: 'image'
			images: post.gallery_data.items.map (image) -> (
				data = post.media_metadata[image.media_id].p.concat post.media_metadata[image.media_id].s
				url_640 = data[0].u
				width_640 = data[0].x
				height_640 = data[0].y
				url_960 = data[0].u
				width_960 = data[0].x
				height_960 = data[0].y
				for d in data
					if width_640 < d.x <= 640
						url_640 = d.u
						width_640 = d.x
						height_640 = d.y
					if width_960 < d.x <= 960
						url_960 = d.u
						width_960 = d.x
						height_960 = d.y
				url_full = data[data.length - 1].u
				width_full = data[data.length - 1].x
				height_full = data[data.length - 1].y
				return {
					url_640,
					url_960,
					url_full,
					width_640,
					width_960,
					width_full,
					height_640,
					height_960,
					height_full,
					caption: image.caption
					caption_url: image.outbound_url
				}
			)
		}
	if post.rpan_video
		return {
			type: 'rpan'
		}
	if post.domain.endsWith 'reddit.com'
		[_, _, _, _, _, _, id, _, comments_root_id, query] = post.url.split '/'
		return {
			type: 'post'
			REFPOST: SINGLEPOST {
				id,
				comments_root_id,
				comments_root_context: (new URLSearchParams query).get 'context'
			}
		}
	switch post.domain
		when 'clips.twitch.tv'
			clip_id = (new URL(post.url)).pathname[1..]
			return {
				type: 'html'
				html: "<iframe src='https://clips.twitch.tv/embed?clip=#{clip_id}&parent=localhost' allowfullscreen='true'></iframe>"
			}
		when 'gfycat.com'
			return {
				type: 'video'
				url: 'https://giant.gfycat.com/' + titlecase_gfycat_video_id post.url[(post.url.lastIndexOf '/' + 1)...] + '.webm'
			}
		when 'redgifs.com'
			return {
				type: 'video'
				url: 'https://thumbs1.redgifs.com/' + titlecase_gfycat_video_id post.url[(post.url.lastIndexOf '/' + 1)...] + '.webm'
			}
		when 'youtu.be'
			video_id = (new URL(post.url)).pathname[1..]
			return {
				type: 'html'
				html: "<iframe src='https://www.youtube.com/embed/#{video_id}?feature=oembed&amp;enablejsapi=1' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen='true'></iframe>"
			}
		when 'youtube.com'
			video_id = (new URL(post.url)).searchParams.get 'v'
			return {
				type: 'html'
				html: "<iframe src='https://www.youtube.com/embed/#{video_id}?feature=oembed&amp;enablejsapi=1' allow='accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture' allowfullscreen='true'></iframe>"
			}
	switch post.post_hint
		when 'link'
			return {
				type: 'link'
				url: post.url
				#HTML: fetch(post.url).then((response) -> response.text())
			}
		when 'image'
			# TODO: Handle GIFs
			optimized_image = post.preview?.images?[0]
			if optimized_image
				data = optimized_image.resolutions.concat optimized_image.source
				url_640 = data[0].url
				width_640 = data[0].width
				height_640 = data[0].height
				url_960 = data[0].url
				width_960 = data[0].width
				height_960 = data[0].height
				for d in data
					if width_640 < d.width <= 640
						url_640 = d.url
						width_640 = d.width
						height_640 = d.height
					if width_960 < d.width <= 960
						url_960 = d.url
						width_960 = d.width
						height_960 = d.height
				url_full = data[data.length - 1].url
				width_full = data[data.length - 1].width
				height_full = data[data.length - 1].height
			else
				url_640 = post.url
				width_640 = undefined
				height_640 = undefined
				url_960 = post.url
				width_960 = undefined
				height_960 = undefined
				url_full = post.url
				width_full = undefined
				height_full = undefined
			return {
				type: 'image'
				images: [{
					url_640,
					url_960,
					url_full,
					width_640,
					width_960,
					width_full,
					height_640,
					height_960,
					height_full,
					caption: null
					caption_url: null
				}]
			}
		when 'hosted:video'
			return {
				type: 'video'
				url: post.secure_media.reddit_video.fallback_url.split('?')[0]
				audio_url: post.secure_media.reddit_video.fallback_url[...post.secure_media.reddit_video.fallback_url.lastIndexOf('/')] + '/audio'
				preview_url: post.secure_media.reddit_video.scrubber_media_url
			}
		when 'rich:video'
			console.log post
	if post.url
		[ i, j, k ] = [
			post.url.indexOf('.', post.url.indexOf('/', post.url.indexOf('//') + 2) + 1),
			post.url.indexOf '?',
			post.url.indexOf '#'
		]
		url_ext = ''
		if j > -1 then url_ext = post.url[(i + 1)...j]
		else if k > -1 then url_ext = post.url[(i + 1)...k]
		else if i > -1 then url_ext = post.url[(i + 1)...]
		switch url_ext
			when 'gif', 'jpg',  'jpeg', 'png', 'webp'
				return {
					type: 'image'
					images: [{
						url_640: post.url,
						url_960: post.url,
						url_full: post.url,
						width_640: undefined,
						width_960: undefined,
						width_full: undefined,
						height_640: undefined,
						height_960: undefined,
						height_full: undefined,
						caption: null
						caption_url: null
					}]
				}
			when 'gifv'
				return {
					type: 'video'
					url: post.url[0...post.url.lastIndexOf('.')] + '.mp4'
				}
		return {
			type: 'link'
			url: post.url
			#HTML: fetch(post.url).then((response) -> response.text())
		}
	return {
		type: 'empty'
	}

titlecase_gfycat_video_id = (video_id) ->
	match_words = () ->
		for adjective_1 in gfycat_adjectives
			if video_id.startsWith adjective_1
				for adjective_2 in gfycat_adjectives
					if video_id[adjective_1.length...].startsWith adjective_2
						for animal in gfycat_animals
							if video_id[(adjective_1.length + adjective_2.length)...] is animal
								return [adjective_1, adjective_2, animal]
		return ['', '', '']
	[adjective_1, adjective_2, animal] = match_words()
	if not (adjective_1 and adjective_2 and animal)
		gfycat_adjectives.reverse()
		[adjective_1, adjective_2, animal] = match_words()
		gfycat_adjectives.reverse()
	if not (adjective_1 and adjective_2 and animal)
		return ''
	return adjective_1[0].toUpperCase() + adjective_1[1...] + adjective_2[0].toUpperCase() + adjective_2[1...] + animal[0].toUpperCase() + animal[1...]

regularize_comments_listing = (comments_listing) ->
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
			comment.is_more = false
			comment.score -= 1 # Don't count the built-in upvote from the commenter
			comment.replies = regularize_comments_listing comment.replies
		return comment