import generalExtractor from '../generalExtractor.coffee'

iFrames = (url) -> switch (if url.hostname.startsWith('www') then url.hostname[4..] else url.hostname)
	when 'clips.twitch.tv'
		id = url.pathname.split('/')[1]
		if id?.length
			src: "https://clips.twitch.tv/embed?clip=#{id}&parent=#{location.hostname}"
		else
			null
	when 'gfycat.com'
		id = url.pathname.split('/')[1]
		if id?.length
			src: "https://gfycat.com/ifr/#{id}"
		else
			null
	when 'redgifs.com'
		id = url.pathname.split('/')[2]
		if id?.length
			src: "https://redgifs.com/ifr/#{id}"
		else
			null
	when 'twitch.tv'
		id = url.pathname.split('/')[3]
		if id?.length
			src: "https://clips.twitch.tv/embed?clip=#{id}&parent=#{location.hostname}"
		else
			null
	when 'youtu.be'
		id = url.pathname.split('/')[1]
		if id?.length
			src: "https://www.youtube.com/embed/#{id}"
			allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
		else
			null
	when 'youtube.com'
		id = url.searchParams.get('v')
		if id?.length and url.pathname.split('/')[1] != 'clip' # clip URLs don't contain the information necessary for embedding
			src: "https://www.youtube.com/embed/#{id}",
			allow: 'accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
		else
			null
	else
		null

# Our "t3" API response type is slightly different from Reddit's "t3" kind.
# Reddit's "t3" kind refers only to bare posts, without their comment replies.
# Our "t3" type refers to "complete" post objects, unifying posts and their comment replies.
# Extracting our desired format out of the API response requires special handling.
# NOTE: Contains unmarked side effects throughout (namely, input data modification).
export default (rawData) ->
	result =
		main: null
		sub: []
	# Process and organize the post data.
	# 1. Extract the bare post from the posts listing.
	#    Put aside the other datasets from the posts listing for the end result.
	{ main: { data: ids }, sub: datasets } = generalExtractor(rawData[0])
	[ barePostDataset, other ] = datasets.partition((dataset) -> dataset.id = ids[0])
	result.sub.concat(other)
	post = barePostDataset.data
	# 2. Normalize the URL - sometimes it is only given as a relative path.
	post.url = if post.url[0] == '/' then new URL("https://www.reddit.com#{post.url}") else new URL(post.url)
	# 3. Detect the content format for the post.
	post.format = switch
		when post.media?.reddit_video or post.is_gallery or post.post_hint == 'image' or post.url.hostname == 'i.redd.it'
			'media'
		when iFrames(post.url)
			'iframe'
		when post.poll_data
			'poll'
		when post.is_self
			'self'
		else
			'link'
	# 4. Organize all the media we might need for the post.
	#    For video or gif media, we also try to organize relevant static images.
	#    Note that self posts sometimes also have media, as inline images.
	hosted_video_data = post.media?.reddit_video
	post.media = [{}]
	if Array.isArray(post.gallery_data) and Array.isArray(post.media_metadata)
		post.media = post.gallery_data.items.map((item) ->
			result = { caption_text: item.caption, caption_url: item.outbound_url }
			data = post.media_metadata[item.media_id]
			if data.s.gif
				result.video_url = data.s.mp4 ? data.s.gif
				result.video_height = data.s.y
				result.video_width = data.s.x
			else
				result.image_url = data.s.u
				result['image_url_' + data.s.x] = data.s.u
			data.p.forEach((res) ->
				result['image_url_' + res.x] = res.u
			)
			return result
		)
	else if post.preview? and Array.isArray(post.preview.images)
		post.media = post.preview.images.map((item) ->
			result = {}
			if item.variants.gif 
				data = item.variants.mp4 ? item.variants.gif
				result.video_url = data.source.url
				result.video_height = data.source.height
				result.video_width = data.source.width
			result.image_url = item.source.url
			result['image_url_' + item.source.width] = item.source.url
			item.resolutions.forEach((res) ->
				result['image_url_' + res.width] = res.url
			)
			return result
		)
	else if post.url.hostname == 'i.redd.it'
		post.media[0] = if post.url.pathname.endsWith('gif') then { video_url: post.url } else { image_url: post.url }
	if hosted_video_data
		post.media[0].video_url = video.fallback_url ? post.url
		post.media[0].video_height = video.height
		post.media[0].video_width = video.width
		post.media[0].video_audio_url = if video.fallback_url and !video.is_gif then video.fallback_url.replaceAll(/DASH_[0-9]+/g, 'DASH_audio') else null
	if iFrames(post.url)
		{ src, allow } = iFrames(post.url)
		post.media[0].iframe_url = src
		post.media[0].iframe_allow = allow
	# Process and organize the comment data.
	# 1. Detect and process a "more comments" object.
	if rawData[1].data.children?.last?.kind is 'more'
		more = rawData[1].data.children.pop()
		post.more_replies = more.data.children
	# 2. Extract the comments from the listing.
	{ main: { data: topLevelCommentIds }, sub: commentDatasets } = generalExtractor(rawData[1])
	# 3. Link the top-level comments via their IDs.
	post.replies = topLevelCommentIds
	# 4. Merge the extracted comment objects into the complete post data.
	result.sub.concat(commentDatasets)
	result.main =
		id: barePostDataset.id
		data: post
	return result