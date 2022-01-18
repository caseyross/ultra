import Subreddit from './Subreddit.coffee'

export default class User
	
	constructor: (data) ->  @[k] = v for k, v of {

		id: data.id.toUserId()
		name: data.name.toLowerCase()
		displayName: data.name
		isRedditEmployee: data.is_employee
		hasRedditPremium: data.is_gold
		isSuspended: data.is_suspended
		profileIsQuarantined: data.quarantine

		signupDate: new Date(Date.seconds(data.created_utc))
		
		postKarma: data.link_karma
		commentKarma: data.comment_karma

		subreddit: new Subreddit(data.subreddit)

	}