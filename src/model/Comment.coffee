import Comments from './Comments'
import Flair from './Flair'
import Score from './Score'

export default class Comment
	constructor: (d) ->
		# BASIC DATA
		@author = d.author
		@content = d.body_html ? ''
		@created_at = new Date(d.created_utc * 1000)
		@distinguish = switch
			when d.distinguished then d.distinguished
			when d.is_submitter then 'original-poster'
			else ''
		@edited_at = new Date(d.edited * 1000)
		@flair = new Flair
			color: d.author_flair_background_color
			text: d.author_flair_text
		@href = '/r/' + d.subreddit + '/post/' + d.link_id[3..] + '/comment/' + d.id
		@id = d.id
		@post =
			id: d.link_id[3..]
			title: d.link_title
		@subreddit = d.subreddit
		# ACTIVITY
		@awards = [] # TODO
		@controversial = Boolean(d.controversiality) # labeled as either 1 or 0, even though the property name sounds like a scalar value
		@score = new Score { hidden: d.score_hidden, value: d.score }
		# REPLIES
		@replies = new Comments(d.replies)
		# STATES
		@edited = d.edited
		@hidden = d.hidden
		@liked = d.likes
		@locked = d.locked
		@nsfw = d.over_18
		@removed = d.body is '[removed]'
		@saved = d.saved
		@stickied = d.stickied
			