import Image from './Image'

export default class Subreddit
	constructor: (r) ->
		# BASIC DATA
		@created_at = new Date(r.created_utc * 1000)
		@id = r.id
		# ALLOWED CONTENT
		@allow_chat_posts = r.allow_chat_post_creation
		@allow_crossposts = r.is_crosspostable_subreddit
		@allow_emojis = r.emojis_enabled
		@allow_galleries = r.allow_galleries
		@allow_images = r.allow_images
		@allow_non_oc = not r.all_original_content
		@allow_oc_tag = r.original_content_tag_enabled
		@allow_polls = r.allow_polls
		@allow_post_flair = r.link_flair_enabled
		@allow_predictions = r.allow_predictions
		@allow_spoiler_tag = r.spoilers_enabled
		@allow_user_flair = r.user_flair_enabled_in_sr
		@allow_user_flair_self_assign = r.can_assign_user_flair
		@allow_videogifs = r.allow_videogifs
		@allow_videos = r.allow_videos
		# COMMENTS CUSTOMIZATION
		@default_comment_sort = r.suggested_comment_sort
		# TEXT CUSTOMIZATION
		@display_name = r.display_name
		@language = r.lang
		@sidebar = r.description
		@tagline = r.public_description
		# VISUAL CUSTOMIZATION
		@banner = new Image
			p: []
			s: [{
				u: r.banner_background_image or r.mobile_banner_image or r.banner_img or ''
			}]
		@color = r.primary_color or r.key_color or 'transparent'
		@icon = new Image
			p: []
			s: [{
				u: r.community_icon or r.icon_img or ''
			}]
		@subbanner = new Image
			p: []
			s: [{
				u: r.header_img
			}]
		# ACTIVITY
		@browser_count = r.accounts_active
		@subscriber_count = r.subscribers
		# STATES
		@access = r.subreddit_type # public, private, restricted, gold_restricted, archived
		@nsfw = r.over18
		@quarantined = r.quarantine