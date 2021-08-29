import Image from '../media/Image.coffee'
import { getSubredditEmojis } from '../API.coffee'

export default class Subreddit

	constructor: (data) ->
		
		getSubredditEmojis(data.display_name.toLowerCase())

		@[k] = v for k, v of {

			id: data.id
			name: data.display_name.toLowerCase()
			displayName: data.display_name
			title: data.title
			blurb: data.public_description
			sidebar: data.description
			isNSFW: data.over18
			isPrivate: data.subreddit_type is 'private'
			isRestricted: data.subreddit_type is 'restricted'
			isRedditPremiumOnly: data.subreddit_type is 'gold_restricted'
			isArchived: data.subreddit_type is 'archived'
			isQuarantined: data.quarantine
			defaultCommentSort: data.suggested_comment_sort

			createDate: new Date(1000 * data.created_utc)

			mainColor: data.primary_color or ''
			auxColor: data.key_color or ''
			icon: new Image
				p: []
				s: [{ u: data.community_icon or data.icon_img or '' }]
			banner: new Image
				p: []
				s: [{ u: data.banner_background_image or data.mobile_banner_img or data.banner_img or '' }]

			numberOfUsersBrowsing: data.accounts_active
			numberOfSubscribers: data.subscribers

		}