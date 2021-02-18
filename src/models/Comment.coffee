import Award from './Award'
import Distinguish from './Distinguish'
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
		@text = r.body
		@replies = new List(r.replies)
		@meta =
			awards:
				list: r.all_awardings.map((a) -> new Award(a))
				spend: r.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
			archived: r.archived
			controversiality: r.controversiality
			distinguish: new Distinguish({
				naive_type: r.distinguished,
				is_op: r.is_submitter
			})
			edit_date:
				if r.edited
					new Date(r.edited * 1000)
				else
					null
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
					'score hidden'
				else
					r.score - 1
			submit_date: new Date(r.created_utc * 1000)