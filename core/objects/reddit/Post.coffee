import { iframes } from '../../../config/integrations.js'
import { fetchPostComments } from '../../logic/API.coffee'
import Flair from './Flair.coffee'
import Subreddit from './Subreddit.coffee'

export default class Post

	constructor: (data) -> @[k] = v for k, v of {

		id: data.id.toPostId()
		subreddit: new Subreddit(data.sr_detail)
		crosspostParent: data.crosspost_parent_list
		href: '/r/' + data.subreddit + '/post/' + data.id.toShortId()

		authorName: data.author
		authorFlair: new Flair
			text: data.author_flair_text
			color: data.author_flair_background_color
		authorRole: data.distinguished
		
		createDate: new Date(Date.seconds(data.created_utc))
		editDate: if data.edited then new Date(Date.seconds(data.edited)) else null

		title: data.title
		titleFlair: new Flair
			text: data.link_flair_text
			color: data.link_flair_background_color
		domain: data.domain
		content: new Content(data)
		isContestMode: data.contest_mode
		isNSFW: data.over_18
		isOC: data.is_original_content
		isSpoiler: data.spoiler
		isArchived: data.archived
		isLocked: data.locked
		isQuarantined: data.quarantine
		isStickied: data.stickied
		wasDeleted: data.selftext is '[removed]'

		score: if data.hide_score then NaN else data.score - 1
		myVote: switch data.likes
			when true then 1
			when false then -1
			else 0
		mySave: data.saved
		myHide: data.hidden

		commentCount: data.num_comments
		comments: fetchPostComments(data.id.toPostId())

	}

Content = (data) ->
	@type = 'LINK'
	@href = data.url
	switch
		when data.media?.reddit_video
			@type = 'VIDEO_NATIVE'
			@video = new Video(data.media.reddit_video)
		when data.is_gallery
			@type = 'IMAGE_NATIVE'
			@images = data.gallery_data.items.map (x) ->
				new Image { ...data.media_metadata[x.media_id], caption: x.caption, link: x.outbound_url }
		when data.post_hint is 'image'
			@type = 'IMAGE_NATIVE'
			@images = [ new Image(data.preview.images[0]) ]
		when data.is_self
			@type = 'TEXT'
			@text = data.selftext_html
		else
			url = new URL(if data.url.startsWith 'https' then data.url else 'https://www.reddit.com' + data.url)
			switch
				when data.domain is 'i.redd.it'
					@type = 'IMAGE_NATIVE'
					@images = [ new Image { p: [], s: [{ u: data.url }] } ]
				when iframes[data.domain] and iframes[data.domain](url)
					@type = 'VIDEO_IFRAME'
					@src = iframes[data.domain](url).src
					@allow = iframes[data.domain](url).allow or ''
				when data.domain.endsWith 'reddit.com'
					[ _, _, _, _, postShortId, _, commentShortId ] = url.pathname.split('/')
					@type = 'REDDIT'
					@postId = postShortId?.toPostId()
					@commentId = commentShortId?.toCommentId()
	return @

# NOTE:
# Reddit only reports a reliable image height for the source image of a series. The reported height for resized images is generally incorrect.
# Thus, we need to determine the resized image heights ourselves.
class Image
	constructor: (d) ->
		switch
			when d.status and not (d.status is 'valid')
				@aspect = 1
				@sizes = [{
					w: 640
					u: '' # TODO: Add error image for invalid images
				}]
			when d.s
				@aspect = d.s.x / d.s.y
				@sizes =
					if d.s.gif
						[{
							w: d.s.x
							u: d.s.gif
						}]
					else
						d.p.concat(d.s).map (resolution) ->
							w: resolution.x
							u: resolution.u
			when d.variants?.gif
				@aspect = d.variants.gif.source.width / d.variants.gif.source.height
				@sizes =
					[{
						w: d.variants.gif.source.width
						u: d.variants.gif.source.url
					}]
			when d.source
				@aspect = d.source.width / d.source.height
				@sizes = d.resolutions.concat(d.source).map (resolution) ->
					w: resolution.width
					u: resolution.url
			else
				@aspect = 1
				@sizes = []
		@sizes.sort (a, b) -> a.w - b.w
		for s in @sizes
			s.h = s.w / @aspect
		@caption =
			if d.caption or d.link
				t: d.caption ? ''
				u: d.link ? ''
			else
				null
	pick: ({ minH, minW, maxH, maxW, maxP }) =>
		@sizes.fold(
			@sizes[0],
			(a, b) => switch
				when a.w < minW then b
				when a.h < minH then b
				when a.w >= maxW then a
				when a.h >= maxH then a
				when a.w * a.h > maxP then a
				else b
		)

Video = (d) ->
	if not d.fallback_url
		alert r
	@width = d.width
	@height = d.height
	@tracks =
		if d.fallback_url # native reddit video
			audio:
				if d.is_gif
					[]
				else
					[
						new MediaSource {
							mime_type: 'audio/mp4'
							codec: 'mp4a.40.2'
							href: d.fallback_url.replaceAll(/DASH_[0-9]+/g, 'DASH_audio')
						}
					]
			video: [
				new MediaSource {
					mime_type: 'video/mp4'
					codec: 'avc1.4D401F' # 4D401E for 480p and below
					href: d.fallback_url
				}
			]
		else # converted GIF video
			audio: []
			video: [
				new MediaSource {
					mime_type: 'video/mp4'
					codec: 'avc1.4D401E' # probably
					href: d.url
				}
			]

MediaSource = ({ mime_type, codec, href }) ->
	@mime_type = mime_type
	@codec = codec
	@href = href