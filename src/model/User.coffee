import Image from './Image'

export default class User
	constructor: (r) ->
		# BASIC DATA
		@created_at = new Date(r.created_utc * 1000)
		@id = r.id
		# TEXT CUSTOMIZATION
		@display_name = r.name
		@tagline = r.subreddit.public_description
		# VISUAL CUSTOMIZATION
		@banner = new Image
			p: []
			s: [{
				u: r.subreddit.banner_img or ''
			}]
		@color = r.subreddit.primary_color or r.subreddit.key_color or 'transparent'
		@icon = new Image
			p: []
			s: [{
				u: r.subreddit.icon_img or ''
			}]
		# ACTIVITY
		@comment_karma = r.comment_karma
		@follower_count = r.subreddit.subscribers
		@post_karma = r.link_karma
		# STATES
		@admin = r.is_employee
		@nsfw = r.subreddit.over18
		@premium = r.is_gold
		@quarantined = r.quarantine