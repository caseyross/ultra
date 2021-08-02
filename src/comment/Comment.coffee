import Flair from '../shared/Flair.coffee'
import Model from '../Model.coffee'
import Score from '../shared/Score.coffee'
import { post } from '../API.coffee'

export default class Comment

	constructor: (data) ->  @[k] = v for k, v of {
		
		id: data.id
		postId: data.link_id[3..]
		postTitle: data.link_title
		postIsNSFW: data.over_18
		subredditName: data.subreddit.toLowerCase()
		subredditDisplayName: data.subreddit
		href: '/r/' + data.subreddit + '/post/' + data.link_id[3..] + '/comment/' + data.id
		
		authorName: data.author
		authorFlair: new Flair
			color: data.author_flair_background_color
			text: data.author_flair_text
		authorRole: switch
			when data.distinguished then data.distinguished
			when data.is_submitter then 'submitter'
			else ''
		
		createDate: new Date(1000 * data.created_utc)
		editDate: new Date(1000 * data.edited)

		content: data.body_html ? ''
		replies: new Model(data.replies)
		isPinned: data.stickied
		wasEdited: data.edited
		wasDeleted: data.body is '[removed]'

		score: new Score
			value: data.score
			hidden: data.score_hidden
		isControversial: Boolean(data.controversiality)
		userUpvoted: data.likes is true
		userDownvoted: data.likes is false
		userSaved: data.saved
		userHid: data.hidden

	}
		
	upvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: 1
	unvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: 0
	downvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: -1
	save: =>
		post
			endpoint: '/api/save'
			content:
				id: 't1_' + this.id
	unsave: =>
		post
			endpoint: '/api/unsave'
			content:
				id: 't1_' + this.id
	hide: =>
		post
			endpoint: '/api/hide'
			content:
				id: 't1_' + this.id
	unhide: =>
		post
			endpoint: '/api/unhide'
			content:
				id: 't1_' + this.id
