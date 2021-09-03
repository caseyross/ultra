import API from '../api/API.coffee'
import Image from '../media/Image.coffee'

export default class Subreddit

	constructor: (data) ->

		object = @[k] = v for k, v of {

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

export getSubreddit = (subredditName) ->
	getSubredditEmojis(subredditName)
	getSubredditWidgets(subredditName)
	API.get
		endpoint: '/r/' + subredditName + '/about'
		cache: 'r/' + subredditName + '/information'
		automodel: true # Subreddit
getSubredditEmojis = (subredditName) ->
	if LS.userKey
		API.get
			endpoint: '/api/v1/' + subredditName + '/emojis/all'
			cache: 'r/' + subredditName + '/emojis'
		.then (x) ->
			emojis = []
			for category of x
				# TODO: store snoomojis as well
				if category isnt 'snoomojis'
					for emoji of x[category]
						[ _, _, _, id, name ] = x[category][emoji].url.split('/')
						emojis.push(name + ':' + id)
			if emojis.length
				LS['emojis@' + subredditName] = emojis.join(',')
	else
		# Can't access subreddit emojis without logging in
		Promise.resolve()
getSubredditWidgets = (subredditName) ->
	API.get
		endpoint: '/r/' + subredditName + '/api/widgets'
		cache: 'r/' + subredditName + '/widgets'
	.then (x) ->
		widgets =
			basicInfo: x.items[x.layout.idCardWidget]
			moderators: x.items[x.layout.moderatorWidget]
			topbar: x.layout.topbar.order.map (id) -> x.items[id]
			sidebar: x.layout.sidebar.order.map (id) -> x.items[id]
		console.log widgets

export getSubredditPosts = (subredditName, { sort = 'hot', quantity }) -> API.get
	endpoint: '/r/' + subredditName + '/' + sort.split('/')[0]
	limit: quantity
	t: sort.split('/')[1]
	cache: ['r', subredditName, sort, quantity].join('/')
	automodel: true # Array[Post]