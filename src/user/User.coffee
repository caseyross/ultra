import Image from '../media/Image.coffee'

export default class User
	
	constructor: (data) ->  @[k] = v for k, v of {

		id: data.id
		name: data.name.toLowerCase()
		displayName: data.name
		tagline: data.subreddit.public_description
		isRedditEmployee: data.is_employee
		hasRedditPremium: data.is_gold
		isSuspended: data.is_suspended
		profileIsNSFW: data.subreddit.over18
		profileIsQuarantined: data.quarantine

		signupDate: new Date(data.created_utc * 1000)

		proileMainColor: data.subreddit.primary_color or ''
		profileSecondaryColor: data.subreddit.key_color or ''
		iconImage: new Image
			p: []
			s: [{ u: data.subreddit.icon_img or '' }]
		profileBannerImage: new Image
			p: []
			s: [{ u: data.subreddit.banner_img or '' }]
		
		postKarma: data.link_karma
		commentKarma: data.comment_karma
		numberOfFollowers: data.subreddit.subscribers

	}

