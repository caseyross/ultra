import ID from '../../../core/ID.coffee'
import html_embeddable from './embeds/html_embeddable.coffee'
import iframe_embeddable from './embeds/iframe_embeddable.coffee'

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
			# Process replies.
			# Comments in raw API data are structured as trees of comments containing other comments and various related objects. Our objective is to "de-link" these tree structures and subsequently identify comments entirely through direct ID reference.
			repliesListing = comment.replies?.data?.children
			if !Array.isArray(repliesListing) then repliesListing = []
			# Detect and process a "more comments" object in the comment's replies.
			if repliesListing.at(-1)?.kind is 'more'
				more = repliesListing.pop().data
				if more.id is '_'
					comment.deeper_replies = true
				else if more.count
					comment.num_more_replies = more.count
					comment.more_replies = if more.children.length then more.children else [more.id]
					more_replies_sort =
						switch ID.type(sourceID)
							when 'post' then ID.var(sourceID, 2) ? 'confidence'
							when 'post_more_replies' then ID.var(sourceID, 3)
							else 'confidence'
					comment.more_replies_id = ID(
						'post_more_replies',
						comment.link_id[3..],
						comment.id,
						more_replies_sort,
						...comment.more_replies
					)
			# Recursively extract all comments in this comment's reply tree.
			repliesListingDatasets = extract(comment.replies or [], sourceID) # Sometimes Reddit sends an empty string instead of an empty array.
			# Set the IDs of the direct replies in place of the original objects.
			comment.replies = repliesListingDatasets.main.data
			result.main =
				id: ID('comment', rawData.data.id) # At the top level of the API response, we don't need the ID, as we already know which ID the data was requested for. However, identifying the ID becomes necessary when an object is nested.
				data: comment
			result.sub = repliesListingDatasets.sub
		when 't2'
			user = rawData.data
			user.profile_color = user.subreddit.icon_color
			user.profile_img = user.icon_img
			delete user.icon_img
			user.profile_over_18 = user.subreddit.over_18
			result.main =
				id: ID('user', user.name)
				data: user
			result.sub.push({
				id: ID('subreddit', user.subreddit.display_name)
				data: user.subreddit
				partial: true # Marks objects known to be an incomplete version of data from another API route.
			})
			delete user.subreddit
		when 't3'
			post = rawData.data
			# Normalize the URL - sometimes it is only given as a relative path.
			post.url = if post.url[0] == '/' then new URL("https://www.reddit.com#{post.url}") else new URL(post.url)
			# Detect the content format for the post.
			post.format = switch
				when post.crosspost_parent_list
					'crosspost'
				when post.media?.reddit_video or post.is_gallery or post.post_hint == 'image' or post.url.hostname == 'i.redd.it'
					'media'
				when post.tournament_data
					'prediction'
				when post.is_self
					'self'
				when html_embeddable(post) or iframe_embeddable(post.url)
					'embed'
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
			else if post.url.hostname == 'i.redd.it'
				post.media[0] =
					image_url: post.url
					is_gif: post.url.pathname.endsWith('gif')
			if hosted_video_data
				video = hosted_video_data
				post.media[0] =
					aspect_ratio: video.width / video.height
					is_gif: video.is_gif
					source_width: video.width
					video_audio_url: if video.fallback_url and !video.is_gif then video.fallback_url.replaceAll(/DASH_[0-9]+/g, 'DASH_audio') else null
					video_url: video.fallback_url ? post.url
			else if iframe_embeddable(post.url)
				post.media[0] = iframe_embeddable(post.url)
			else if html_embeddable(post)
				post.media[0] = html_embeddable(post)
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
			# Done.
			result.main =
				id: ID('post', rawData.data.id)
				data: post
				partial: true
		when 't4'
			result.main =
				id: ID('private_message', rawData.data.id)
				data: rawData.data
		when 't5'
			result.main =
				id: ID('subreddit', rawData.data.display_name)
				data: rawData.data
		when 'wikipage'
			wikipage = rawData.data
			revised_by_user_id = ID('user', wikipage.revision_by.data.name)
			result.sub.push({
				id: revised_by_user_id
				data: wikipage.revision_by.data
			})
			wikipage.revision_by = revised_by_user_id
			result.main =
				id: null
				data: wikipage
		when 'LabeledMulti'
			result.main =
				id: ID('multireddit', rawData.data.owner, rawData.data.name)
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
		when 'LiveUpdate'
			result.main =
				id: null # NOTE: We'd like to assign these as "livethread_update", since live updates appear to have globally unique IDs. Unfortunately, there's no endpoint available to get an update solely by its ID (need thread ID as well), so assigning IDs here would break our data modeling assumptions.
				data: rawData.data
		when 'LiveUpdateEvent'
			result.main =
				id: ID('livethread', rawData.data.id)
				data: rawData.data
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