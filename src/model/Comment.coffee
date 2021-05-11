import Comments from './Comments'
import Flair from './Flair'
import Score from './Score'

export default class Comment
	constructor: (r) ->
		# BASIC DATA
		@author = r.author
		@content = r.body ? ''
		@created_at = new Date(r.created_utc * 1000)
		@distinguish = switch
			when r.distinguished then r.distinguished
			when r.is_submitter then 'original-poster'
			else ''
		@edited_at = new Date(r.edited * 1000)
		@flair = new Flair
			color: r.author_flair_background_color
			text: r.author_flair_text
		@href = '/r/' + r.subreddit + '/post/' + r.link_id[3..] + '/comment/' + r.id
		@id = r.id
		@post =
			id: r.link_id[3..]
			title: r.link_title
		@subreddit = r.subreddit
		# ACTIVITY
		@awards = [] # TODO
		@controversiality = r.controversiality
		@score = new Score { hidden: r.score_hidden, value: r.score }
		# REPLIES
		@replies = new Comments(r.replies)
		# STATES
		@edited = r.edited
		@hidden = r.hidden
		@liked = r.likes
		@locked = r.locked
		@nsfw = r.over_18
		@removed = r.body is '[removed]'
		@saved = r.saved
		@stickied = r.stickied
			