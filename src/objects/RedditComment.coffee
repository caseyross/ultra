import RedditDistinguish from '/src/objects/RedditDistinguish'
import RedditFeed from '/src/objects/RedditFeed'
import RedditFlair from '/src/objects/RedditFlair'
import RedditList from '/src/objects/RedditList'
import RedditUser from '/src/objects/RedditUser'

export default class RedditComment
	constructor: (raw) ->
		@awards =
			list: raw.all_awardings
			spend: raw.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
		@author = new RedditUser(raw.author)
		@content =
			text: raw.body_html[16...-6]
		@distinguish = new RedditDistinguish(raw.distinguished, raw.is_submitter)
		@flags =
			archived: raw.archived
			edited: raw.edited
			locked: raw.locked
			nsfw: raw.over_18
			pinned: raw.stickied
			quarantined: raw.quarantine
			removed: raw.body is '[removed]'
			saved: raw.saved
			scoreHidden: raw.score_hidden
		@flairs =
			author: new RedditFlair(raw.author_flair_text, raw.author_flair_background_color)
		@id = 'c' + raw.id.toUpperCase()
		@nativeFeed = new RedditFeed({ fromId: 'r/' + raw.subreddit })
		@postId = 'p' + raw.link_id[3..].toUpperCase()
		@replies = new RedditList(raw.replies)
		@times =
			edit: raw.edited or NaN
			parse: Date.now() // 1000
			submit: raw.created_utc
		@stats =
			controversiality: raw.controversiality
			score: if raw.score_hidden then 0 else raw.score - 1
			rating: Math.log(Statistics.normalizedLength(raw.body_html)) - Math.log((@times.parse - @times.submit) / 6000) + (if raw.score > 1 then Math.log(raw.score - 1) else if raw.score is 1 then 0 else -1)
			ratingExplanation: "LEN: #{Math.log(Statistics.normalizedLength(raw.body_html))}  TIME: #{Math.log((@times.parse - @times.submit) / 6000)}  SCORE: #{if raw.score > 1 then Math.log(raw.score - 1) else if raw.score is 1 then 0 else -1}"