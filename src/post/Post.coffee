import Flair from '../shared/Flair.coffee'
import PostContent from './content/PostContent.coffee'
import Score from '../shared/Score.coffee'
import { getPostComments, post } from '../API.coffee'

export default class Post

	constructor: (data) -> @[k] = v for k, v of {

		id: data.id
		subredditName: data.subreddit
		crosspostParent: data.crosspost_parent_list
		href: '/r/' + data.subreddit + '/post/' + data.id

		authorName: data.author
		authorFlair: new Flair
			text: data.author_flair_text
			color: data.author_flair_background_color
		authorRole: data.distinguished or 'submitter'
		
		createDate: new Date(1000 * data.created_utc)
		editDate: new Date(1000 * (data.edited or data.created_utc))

		title: data.title
		titleFlair: new Flair
			text: data.link_flair_text
			color: data.link_flair_background_color
		content: new PostContent(data)
		isContestMode: data.contest_mode
		isNSFW: data.over_18
		isOC: data.is_original_content
		isSpoiler: data.spoiler
		isArchived: data.archived
		isLocked: data.locked
		isQuarantined: data.quarantine
		isStickied: data.stickied
		isSuperStickied: data.pinned
		wasEdited: data.edited
		wasDeleted: data.selftext is '[removed]'

		score: new Score
			value: data.score
			hidden: data.hide_score
		userUpvoted: data.likes is true
		userDownvoted: data.likes is false
		userSaved: data.saved
		userHid: data.hidden

		comments: getPostComments(data.id)

	}

	upvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't3_' + this.id
				dir: 1
	unvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't3_' + this.id
				dir: 0
	downvote: =>
		post
			endpoint: '/api/vote'
			content:
				id: 't3_' + this.id
				dir: -1
	save: =>
		post
			endpoint: '/api/save'
			content:
				id: 't3_' + this.id
	unsave: =>
		post
			endpoint: '/api/unsave'
			content:
				id: 't3_' + this.id
	hide: =>
		post
			endpoint: '/api/hide'
			content:
				id: 't3_' + this.id
	unhide: =>
		post
			endpoint: '/api/unhide'
			content:
				id: 't3_' + this.id
