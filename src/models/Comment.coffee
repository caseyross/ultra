import Award from './Award'
import Feed from './Feed'
import Flair from './Flair'
import List from './List'
import User from './User'

export default class Comment
	constructor: (r) ->
		@id = r.id
		@author = new User({
			name: r.author
			flair: new Flair({
				text: r.author_flair_text,
				color: r.author_flair_background_color
			})
		})
		@text = r.body_html
		@replies = new List(r.replies)
		@meta =
			author_relation: switch
				when r.distinguished
					r.distinguished
				when r.is_submitter
					'submitter'
				else
					''
			archived: r.archived
			awards: r.all_awardings
			controversiality: r.controversiality
			edit_date:
				if r.edited
					new Date(r.edited * 1000)
				else
					null
			hype: NaN # to be set by requester
			locked: r.locked
			native_feed: new Feed({ name: 'r/' + r.subreddit })
			nsfw: r.over_18
			pinned: r.stickied
			post_id: r.link_id[3..]
			quarantined: r.quarantine
			removed: r.body is '[removed]'
			saved: r.saved
			score:
				if r.score_hidden
					NaN
				else
					r.score
			submit_date: new Date(r.created_utc * 1000)