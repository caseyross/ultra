import Flair from '../wrapper/Flair'
import Score from '../wrapper/Score'

import MoreCommentsReference from './MoreCommentsReference'
import PostReference from './PostReference'
import ThingList from './ThingList'
import SubredditReference from './SubredditReference'
import UserReference from './UserReference'

export default class CommentSnapshot
	constructor: (r) ->
		@activity =
			awards: [] # TODO
			controversiality: r.controversiality
			liked: r.likes
			saved: r.saved
			score: new Score
				hidden: r.score_hidden
				value: r.score
		@author = new UserReference r.author
		@content = r.body ? ''
		@date =
			create: new Date(r.created_utc * 1000)
			edit: new Date(r.edited * 1000)
		@distinguish = switch
			when r.distinguished then r.distinguished
			when r.is_submitter then 'poster'
			else ''
		@flair = new Flair
			color: r.author_flair_background_color
			text: r.author_flair_text
		@id = r.id
		@post = new PostReference r.link_id[3..]
		@post_title = r.link_title
		@replies = new ThingList(r.replies)
		@state =
			edited: r.edited
			hidden: r.hidden
			locked: r.locked
			nsfw: r.over_18
			pinned: r.stickied
			removed: r.body is '[removed]'
		@subreddit = new SubredditReference r.subreddit
			