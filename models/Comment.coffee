import Flair from './Flair.coffee'
import Listing from './Listing.coffee'

export default class Comment

	constructor: (data) -> @[k] = v for k, v of {
			
		id: data.id.toCommentId()
		postId: data.link_id.toPostId()
		postTitle: data.link_title
		postIsNSFW: data.over_18
		subreddit:
			name: data.subreddit.toLowerCase()
		href: '/r/' + data.subreddit + '/post/' + data.link_id.toShortId() + '/comment/' + data.id.toShortId()
		
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
		editDate: if data.edited then new Date(1000 * data.edited) else null

		content: data.body_html ? ''
		replies: new Listing(data.replies) # Array[Comment/MoreComments]
		isPinned: data.stickied

		score: if data.score_hidden then NaN else data.score - 1
		isControversial: Boolean(data.controversiality)
		myVote: switch data.likes
			when true then 1
			when false then -1
			else 0
		mySave: data.saved
		myHide: data.hidden

	}