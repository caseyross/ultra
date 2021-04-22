import Flair from '../wrapper/Flair'
import Score from '../wrapper/Score'

import MoreCommentsReference from './MoreCommentsReference'
import PostReference from './PostReference'
import ThingList from './ThingList'
import SubredditReference from './SubredditReference'
import UserReference from './UserReference'

export default class CommentSnapshot
	constructor: (r) ->
		# BASIC DATA
		@author = new UserReference r.author
		@content = r.body ? ''
		@created_at = new Date(r.created_utc * 1000)
		@distinguish = switch
			when r.distinguished then r.distinguished
			when r.is_submitter then 'original-poster'
			else ''
		@edited_at = new Date(r.edited * 1000)
		@flairs =
			author: new Flair
				color: r.author_flair_background_color
				text: r.author_flair_text
		@id = r.id
		@post =
			ref: new PostReference r.link_id[3..]
			title: r.link_title
		@subreddit = new SubredditReference r.subreddit
		# ACTIVITY
		@awards = [] # TODO
		@controversiality = r.controversiality
		@score = new Score { hidden: r.score_hidden, value: r.score }
		# REPLIES
		@replies = new ThingList(r.replies)
		# STATES
		@edited = r.edited
		@hid = r.hidden
		@liked = r.likes
		@locked = r.locked
		@nsfw = r.over_18
		@removed = r.body is '[removed]'
		@saved = r.saved
		@stickied = r.stickied
			