import API from '../api/API.coffee'
import Model from '../model/Model.coffee'
import Flair from '../media/Flair.coffee'

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
			when data.author is '[deleted]' then 'deleted'
			when data.distinguished then data.distinguished
			when data.is_submitter then 'submitter'
			else ''
		
		createDate: new Date(1000 * data.created_utc)
		editDate: new Date(1000 * data.edited)

		content: data.body_html ? ''
		replies: new Model(data.replies) # Array[Comment/MoreComments]
		isPinned: data.stickied
		wasEdited: data.edited

		score: if data.score_hidden then NaN else data.score
		isControversial: Boolean(data.controversiality)
		userUpvoted: data.likes is true
		userDownvoted: data.likes is false
		userSaved: data.saved
		userHid: data.hidden

	}
		
	upvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't1_' + this.id
			dir: 1
	unvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't1_' + this.id
			dir: 0
	downvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't1_' + this.id
			dir: -1
	save: =>
		API.post
			endpoint: '/api/save'
			id: 't1_' + this.id
	unsave: =>
		API.post
			endpoint: '/api/unsave'
			id: 't1_' + this.id
	hide: =>
		API.post
			endpoint: '/api/hide'
			id: 't1_' + this.id
	unhide: =>
		API.post
			endpoint: '/api/unhide'
			id: 't1_' + this.id
