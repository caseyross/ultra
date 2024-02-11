import ID from '../../base/ID.coffee'

# Separate and extract independent Reddit entities from raw API data.
# Primarily useful to parse Reddit's "Listing" and "Thing" data structures, and to flatten comment trees for store ingestion.
# All extractors return the same data structure. It is described below as it is constructed.
# NOTE: Contains side effects throughout (namely, input data modification).
export default extract = (rawData, sourceID) ->
	result =
		main: null # The object specified by an API route.
		sub: [] # Objects contained in the same API response as the main objects, but which "belong" to a different API route.
	switch rawData.kind
		when 't1'
			comment = rawData.data
			# Check if the comment is actually a private message.
			# Reddit marks PMs that represent comments as `t1` like normal comments, even though the data structure matches `t4`.
			if comment.was_comment
				return extract({ kind: 't4', data: comment })
			# Process replies.
			# Comments in raw API data are structured as trees of comments containing other comments and various related objects. Our objective is to "de-link" these tree structures and subsequently identify comments entirely through direct ID reference.
			repliesListing = comment.replies?.data?.children
			if !Array.isArray(repliesListing) then repliesListing = []
			# Detect and process a "more comments" object in the comment's replies.
			if repliesListing.at(-1)?.kind is 'more'
				comments_sort =
					switch ID.type(sourceID)
						when 'post' then ID.var(sourceID, 2) ? 'confidence'
						when 'post_more_replies' then ID.var(sourceID, 2)
						else 'confidence'
				more = repliesListing.pop().data
				if more.id is '_'
					comment.deeper_replies = true
					comment.deeper_replies_id = ID(
						'post',
						comment.link_id[3..],
						comments_sort,
						ID.var(sourceID, 3),
						comment.id
					)
				else if more.count
					comment.num_more_replies = more.count
					comment.more_replies = if more.children.length then more.children else [more.id]
					comment.more_replies_id = ID(
						'post_more_replies',
						comment.link_id[3..],
						comments_sort,
						ID.var(sourceID, 3),
						comment.id,
						comment.more_replies.join(',')
					)
			# Recursively extract all comments in this comment's reply tree.
			repliesListingDatasets = extract(comment.replies or [], sourceID) # Sometimes Reddit sends an empty string instead of an empty array.
			# Set the IDs of the direct replies in place of the original objects.
			comment.replies = repliesListingDatasets.main.data
			result.main =
				id: ID('comment', rawData.data.id) # At the top level of the API response, we don't need the ID, as we already know which ID the data was requested for. However, identifying the ID becomes necessary when an object is nested.
				data: comment
				merge: true # Merge this dataset with previous versions of the same dataset, instead of simply overwriting like normal.
			result.sub = repliesListingDatasets.sub
		when 't2'
			user = rawData.data
			user.profile_img = user.icon_img
			delete user.icon_img
			if user.subreddit
				user.profile_color = user.subreddit.icon_color
				user.profile_over_18 = user.subreddit.over_18
				result.sub.push({
					id: ID('subreddit', user.subreddit.display_name)
					data: user.subreddit
					partial: true # Marks objects known to be an incomplete version of data from another API route.
				})
				delete user.subreddit
			result.main =
				id: ID('user', user.name)
				data: user
		when 't3'
			post = rawData.data
			# Normalize the URL - sometimes it is only given as a relative path.
			post.url = switch
				when !post.url then null
				when post.url[0] == '/' then new URL("https://www.reddit.com#{post.url}")
				else new URL(post.url)
			# Detect the content format for the post.
			post.format = switch
				when post.crosspost_parent_list?.length
					'crosspost'
				when post.live_audio
					'talk'
				when post.tournament_data
					'prediction'
				when post.media?.reddit_video
					'video'
				when post.is_gallery or post.post_hint == 'image' or post.url?.hostname == 'i.redd.it'
					'image'
				when post.is_self
					'self'
				else
					'link'
			# Organize all the media we might need for the post.
			# Any type of post can have media, not just media-format posts. For example, self posts can have inline images.
			# We try to maintain different representations of media where provided; for example, image previews of videos/GIFs.
			hosted_video_data = post.media?.reddit_video
			post.media = []
			if post.media_metadata and post.gallery_data and Array.isArray(post.gallery_data.items)
				post.media = post.gallery_data.items.map((item) ->
					mediaObject = { caption_text: item.caption, caption_url: item.outbound_url }
					data = post.media_metadata[item.media_id]
					if data.status isnt 'valid'
						mediaObject.image_url = null
					if data.s
						mediaObject.aspect_ratio = data.s.x / data.s.y
						mediaObject.source_width = data.s.x
						if data.s.mp4
							mediaObject.video_url = data.s.mp4
						if data.s.gif
							mediaObject.is_gif = true
							mediaObject.image_url = data.s.gif
							mediaObject['image_url_' + data.s.x] = data.s.gif
						else
							mediaObject.image_url = data.s.u
							mediaObject['image_url_' + data.s.x] = data.s.u
					if data.p
						data.p.forEach((res) ->
							mediaObject['image_url_' + res.x] = res.u
						)
					return mediaObject
				)
			else if post.preview? and Array.isArray(post.preview.images)
				post.media = post.preview.images.map((item) ->
					mediaObject = {}
					if item.variants.mp4
						data = item.variants.mp4
						mediaObject.video_url = data.source.url
					if item.variants.gif
						mediaObject.is_gif = true
						data = item.variants.gif
						mediaObject.image_url = data.source.url
						mediaObject['image_url_' + data.source.width] = data.source.url
					else
						mediaObject.image_url = item.source.url
						mediaObject['image_url_' + item.source.width] = item.source.url
					item.resolutions.forEach((res) ->
						mediaObject['image_url_' + res.width] = res.url
					)
					mediaObject.aspect_ratio = item.source.width / item.source.height
					mediaObject.source_width = item.source.width
					return mediaObject
				)
			else if post.url?.hostname == 'i.redd.it'
				post.media[0] =
					image_url: post.url.toString()
					is_gif: post.url.pathname.endsWith('gif')
			if hosted_video_data
				video = hosted_video_data
				if !post.media[0]
					post.media[0] = {}
				post.media[0].video_aspect_ratio = video.width / video.height
				post.media[0].video_is_gif = video.is_gif
				post.media[0].video_source_width = video.width
				if video.fallback_url
					video_url = new URL(video.fallback_url)
					post.media[0].video_url = video_url
					audio_url = new URL(video_url)
					if post.created_utc >= 1690502400
						# Newest videos (uploaded after approx. 2023-7-27)
						audio_url.pathname = audio_url.pathname.replaceAll(/DASH_[0-9]+/g, 'DASH_AUDIO_64')
					else if /DASH_[0-9]+\./.test(audio_url.pathname)
						# Somewhat older videos (uploaded approx. 2020 to 2023-7-27)
						audio_url.pathname = audio_url.pathname.replaceAll(/DASH_[0-9]+/g, 'DASH_audio')
					else
						# Older videos.
						audio_path = video_url.pathname.split('/')
						audio_path[audio_path.length - 1] = 'audio'
						audio_url.pathname = audio_path.join('/')
					post.media[0].video_audio_url = audio_url
				else
					post.media[0].video_url = post.url
			# Process crosspost source, if present.
			if post.crosspost_parent_list?.length
				crosspost_datasets = extract(
					{
						kind: 't3'
						data: post.crosspost_parent_list[0]
					}
				)
				result.sub.push(crosspost_datasets.main, ...crosspost_datasets.sub)
				post.crosspost_parent = post.crosspost_parent_list[0].id
				delete post.crosspost_parent_list
			# Process subreddit information, if present.
			if post.sr_detail
				result.sub.push({
					id: ID('subreddit', post.subreddit)
					data: post.sr_detail
					partial: true
				})
				delete post.sr_detail
			# Setup contributors list.
			post.contributors = if post.author_fullname? then [post.author_fullname[3..]] else []
			# Done.
			result.main =
				id: ID('post', rawData.data.id)
				data: post
		when 't4'
			result.main =
				id: null # "message-type" private messages have independent IDs, but "comment-type" PMs don't
				data: rawData.data
		when 't5'
			result.main =
				id: ID('subreddit', rawData.data.display_name)
				data: rawData.data
		when 'wikipage'
			wikipage = rawData.data
			if wikipage.content_html?.kind == 'stylesheet'
				wikipage.content_css = wikipage.content_html.data.stylesheet
				delete wikipage.content_html
			if wikipage.revision_by
				result.sub.push({
					id: ID('user', wikipage.revision_by.data.name)
					data: wikipage.revision_by.data
				})
				wikipage.revision_by = wikipage.revision_by.data.name
			result.main =
				id: null
				data: wikipage
		when 'wikipagelisting'
			result.main =
				id: null
				data: rawData.data
		when 'LabeledMulti'
			for subreddit in rawData.data.subreddits
				if subreddit.data
					result.sub.push({
						id: ID('subreddit', subreddit.name)
						data: subreddit.data
					})
			rawData.data.subreddits = rawData.data.subreddits.map((subreddit) -> subreddit.name)
			result.main =
				id: ID('multireddit', "#{rawData.data.owner}-#{rawData.data.name}")
				data: rawData.data
		when 'Listing'
			listing = rawData.data.children
			if !Array.isArray(listing) then listing = []
			# If each top-level object in the listing is referenceable by ID, the primary data becomes simply an array of short-IDs.
			# If not, the primary data contains the full child objects.
			listingDatasets = listing.map((item) -> extract(item, sourceID))
			childIds = listingDatasets.map(({ main }) -> main.id)
			if childIds.every((id) -> id?)
				result.main =
					id: null
					data: childIds.map((id) -> ID.var(id, 1))
				result.sub = listingDatasets.flatMap(({ main, sub }) -> sub.concat(main))
			else
				result.main =
					id: null
					data: listingDatasets.map(({ main }) -> main.data)
				result.sub = listingDatasets.flatMap(({ sub }) -> sub)
		when 'TrophyList'
			result.main =
				id: null
				data: rawData.data.trophies.map((item) -> item.data)
		when 'UserList'
			result.main =
				id: null
				data: rawData.data.children
		else
			if Array.isArray(rawData)
				# Essentially the same logic as for listings.
				arrayDatasets = rawData.map((child) -> extract(child, sourceID))
				childIds = arrayDatasets.map(({ main }) -> main.id)
				if childIds.every((id) -> id?)
					result.main =
						id: null
						data: childIds.map((id) -> ID.var(id, 1))
					result.sub = arrayDatasets.flatMap(({ main, sub }) -> sub.concat(main))
				else
					result.main =
						id: null
						data: arrayDatasets.map(({ main }) -> main.data)
					result.sub = arrayDatasets.flatMap(({ sub }) -> sub)
			else
				result.main =
					id: null
					data: rawData
	return result