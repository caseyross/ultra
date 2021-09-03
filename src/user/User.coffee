import API from '../api/API.coffee'
import Subreddit from '../subreddit/Subreddit.coffee'

export default class User
	
	constructor: (data) ->  @[k] = v for k, v of {

		id: data.id
		name: data.name.toLowerCase()
		displayName: data.name
		isRedditEmployee: data.is_employee
		hasRedditPremium: data.is_gold
		isSuspended: data.is_suspended
		profileIsQuarantined: data.quarantine

		signupDate: new Date(data.created_utc * 1000)
		
		postKarma: data.link_karma
		commentKarma: data.comment_karma

		subreddit: new Subreddit(data.subreddit)

	}


export getUser = (userName) -> API.get
	endpoint: '/user/' + userName + '/about'
	cache: 'u/' + userName + '/about'
	automodel: true # User

export getUserItems = (userName, { filter = 'overview', sort = 'new', quantity }) -> API.get
	endpoint: '/user/' + userName + '/' + filter
	limit: quantity
	sort: sort.split('/')[0]
	t: sort.split('/')[1]
	cache: ['u', userName, filter, sort, quantity].join('/')
	automodel: true # Array[Post/Comment]