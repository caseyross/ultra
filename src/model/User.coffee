import Image from './Image'

export default class User
	constructor: (d) ->
		# BASIC DATA
		@created_at = new Date(d.created_utc * 1000)
		@id = d.id
		# TEXT CUSTOMIZATION
		@display_name = d.name
		@tagline = d.subreddit.public_description
		# VISUAL CUSTOMIZATION
		@banner = new Image
			p: []
			s: [{
				u: d.subreddit.banner_img or ''
			}]
		@color = d.subreddit.primary_color or d.subreddit.key_color or 'transparent'
		@icon = new Image
			p: []
			s: [{
				u: d.subreddit.icon_img or ''
			}]
		# ACTIVITY
		@comment_karma = d.comment_karma
		@follower_count = d.subreddit.subscribers
		@post_karma = d.link_karma
		# STATES
		@admin = d.is_employee
		@nsfw = d.subreddit.over18
		@premium = d.is_gold
		@quarantined = d.quarantine