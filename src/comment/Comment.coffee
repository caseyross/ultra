import Flair from '../shared/Flair'
import RepliesArray from './RepliesArray.coffee'
import Score from '../shared/Score'

export default class Comment

	constructor: (data) ->  @[k] = v for k, v of {
		
		id: data.id
		postId: data.link_id[3..]
		postTitle: data.link_title
		postIsNSFW: data.over_18
		subredditName: data.subreddit
		href: '/r/' + data.subreddit + '/post/' + data.link_id[3..] + '/comment/' + data.id
		
		author: data.author
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
		replies: new RepliesArray(data.replies, this.postId)
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
		API.post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: 1
	unvote: =>
		API.post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: 0
	downvote: =>
		API.post
			endpoint: '/api/vote'
			content:
				id: 't1_' + this.id
				dir: -1
	save: =>
		API.post
			endpoint: '/api/save'
			content:
				id: 't1_' + this.id
	unsave: =>
		API.post
			endpoint: '/api/unsave'
			content:
				id: 't1_' + this.id
	hide: =>
		API.post
			endpoint: '/api/hide'
			content:
				id: 't1_' + this.id
	unhide: =>
		API.post
			endpoint: '/api/unhide'
			content:
				id: 't1_' + this.id
