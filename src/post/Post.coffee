import API from '../api/API.coffee'
import Model from '../model/Model.coffee'
import Content from '../content/Content.coffee'
import Flair from '../media/Flair.coffee'
import Subreddit from '../subreddit/Subreddit.coffee'

export default class Post

	constructor: (data) -> @[k] = v for k, v of {

		id: data.id
		subreddit: new Subreddit(data.sr_detail)
		crosspostParent: data.crosspost_parent_list
		href: '/r/' + data.subreddit + '/post/' + data.id

		authorName: data.author
		authorFlair: new Flair
			text: data.author_flair_text
			color: data.author_flair_background_color
		authorRole: data.distinguished
		
		createDate: new Date(1000 * data.created_utc)
		editDate: if data.edited then new Date(1000 * data.edited) else null

		title: data.title
		titleFlair: new Flair
			text: data.link_flair_text
			color: data.link_flair_background_color
		domain: data.domain
		content: new Content(data)
		isContestMode: data.contest_mode
		isNSFW: data.over_18
		isOC: data.is_original_content
		isSpoiler: data.spoiler
		isArchived: data.archived
		isLocked: data.locked
		isQuarantined: data.quarantine
		isStickiedInHomeChannel: data.stickied
		isStickiedInThisChannel: if data.subreddit_type is 'user' then data.pinned else data.stickied
		wasDeleted: data.selftext is '[removed]'

		score: if data.hide_score then NaN else data.score - 1
		userVote: switch data.likes
			when true then 1
			when false then -1
			else 0
		userSaved: data.saved
		userHid: data.hidden

		commentCount: data.num_comments
		comments: getPostComments(data.id)

	}

	upvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't3_' + this.id
			dir: 1
	unvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't3_' + this.id
			dir: 0
	downvote: =>
		API.post
			endpoint: '/api/vote'
			id: 't3_' + this.id
			dir: -1
	save: =>
		API.post
			endpoint: '/api/save'
			id: 't3_' + this.id
	unsave: =>
		API.post
			endpoint: '/api/unsave'
			id: 't3_' + this.id
	hide: =>
		API.post
			endpoint: '/api/hide'
			id: 't3_' + this.id
	unhide: =>
		API.post
			endpoint: '/api/unhide'
			id: 't3_' + this.id

export getPost = (id) ->
	API.get
		endpoint: '/comments/' + id
		cache: 't3_' + id
	.then ([x, y]) ->
		# The post's comments are handled separately.
		new Model(x)[0] # Post

export getPostComments = (id) ->
	API.get
		endpoint: '/comments/' + id
		cache: 't3_' + id
	.then ([x, y]) ->
		new Model(y) # Array[Comment/MoreComments]