import Image from './Image'

export default class Subreddit
	constructor: (d) ->
		# BASIC DATA
		@created_at = new Date(d.created_utc * 1000)
		@id = d.id
		# ALLOWED CONTENT
		@allow_chat_posts = d.allow_chat_post_creation
		@allow_crossposts = d.is_crosspostable_subreddit
		@allow_emojis = d.emojis_enabled
		@allow_galleries = d.allow_galleries
		@allow_images = d.allow_images
		@allow_non_oc = not d.all_original_content
		@allow_oc_tag = d.original_content_tag_enabled
		@allow_polls = d.allow_polls
		@allow_post_flair = d.link_flair_enabled
		@allow_predictions = d.allow_predictions
		@allow_spoiler_tag = d.spoilers_enabled
		@allow_user_flair = d.user_flair_enabled_in_sr
		@allow_user_flair_self_assign = d.can_assign_user_flair
		@allow_videogifs = d.allow_videogifs
		@allow_videos = d.allow_videos
		# COMMENTS CUSTOMIZATION
		@default_comment_sort = d.suggested_comment_sort
		# TEXT CUSTOMIZATION
		@display_name = d.display_name
		@language = d.lang
		@sidebar = d.description
		@tagline = d.public_description
		# VISUAL CUSTOMIZATION
		@banner = new Image
			p: []
			s: [{
				u: d.banner_background_image or d.mobile_banner_image or d.banner_img or ''
			}]
		@color = d.primary_color or d.key_color or 'transparent'
		@icon = new Image
			p: []
			s: [{
				u: d.community_icon or d.icon_img or ''
			}]
		@subbanner = new Image
			p: []
			s: [{
				u: d.header_img
			}]
		# ACTIVITY
		@browser_count = d.accounts_active
		@subscriber_count = d.subscribers
		# STATES
		@access = d.subreddit_type # public, private, restricted, gold_restricted, archived
		@nsfw = d.over18
		@quarantined = d.quarantine