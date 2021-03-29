import { Award, Flair, Score, Subreddit } from '../'
import ModeledArray from '../ModeledArray'

export default class Comment
	constructor: (r) ->
		@author =
			flair: new Flair { text: r.author_flair_text, color: r.author_flair_background_color }
			name: r.author
			relation: switch
				when r.distinguished then r.distinguished
				when r.is_submitter then 'submitter'
				else ''
		@edit_date =
			if r.edited then new Date(r.edited * 1000)
			else null
		@engagement =
			awards: r.all_awardings.map((x) -> new Award(x))
			controversiality: r.controversiality
			score: new Score { value: r.score, hidden: r.score_hidden }
		@id = 't1_' + r.id
		@post_id = r.link_id
		@replies = new ModeledArray(r.replies)
		@tags =
			archived: r.archived
			locked: r.locked
			not_safe_for_work: r.over_18
			pinned: r.stickied
			quarantined: r.quarantine
			removed: r.body is '[removed]'
			saved: r.saved
		@text = r.body_html
		@submit_date = new Date(r.created_utc * 1000)
		@subreddit = new Subreddit { name: r.subreddit }