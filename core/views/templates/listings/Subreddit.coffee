export default class Subreddit

	constructor: (data) -> @[k] = v for k, v of {

		id: (data.id or data.name).toSubredditId()
		name: data.display_name.toLowerCase()
		isNSFW: data.over18
		isPrivate: data.subreddit_type is 'private'
		isRestricted: data.subreddit_type is 'restricted'
		isPremiumOnly: data.subreddit_type is 'gold_restricted'
		isArchived: data.subreddit_type is 'archived'
		isQuarantined: data.quarantine
		preferredCommentSort: data.suggested_comment_sort

		createDate: new Date(Date.seconds(data.created_utc))

		displayName: data.display_name
		tagline: data.title
		elevatorPitch: data.public_description
		
		color: data.primary_color or data.key_color or '#ff4500' # orangered
		iconUrl: data.community_icon or data.icon_img or ''
		bannerUrl: data.banner_background_image or data.mobile_banner_img or data.banner_img or ''

		numberOfUsersBrowsing: data.accounts_active or NaN
		numberOfSubscribers: data.subscribers or NaN

	}