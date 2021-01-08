import RedditFeed from '/objects/RedditFeed.coffee'
import RedditFlair from '/objects/RedditFlair.coffee'
import RedditList from '/objects/RedditList.coffee'
import RedditUser from '/objects/RedditUser.coffee'

export default class RedditComment
	constructor: (raw) ->
		@awards =
			list: raw.all_awardings
			spend: raw.all_awardings.fold(0, (a, b) -> a + b.coin_price * b.count)
		@author = new RedditUser(raw.author)
		@distinguish = switch
			when raw.is_submitter then 'op'
			when raw.distinguished is 'moderator' then 'mod'
			else raw.distinguished
		@content =
			text: raw.body_html[16...-6]
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
		@nativeFeed = new RedditFeed(raw.subreddit_name_prefixed)
		@postId = 'p' + raw.link_id[3..].toUpperCase()
		@replies = new RedditList(raw.replies)
		@times =
			edit: raw.edited or NaN
			parse: Date.now() // 1000
			submit: raw.created_utc
		@stats =
			controversiality: raw.controversiality
			score: raw.score - 1
			rating: Math.log(Statistics.normalizedLength(raw.body_html)) - Math.log((@times.parse - @times.submit) / 60) + (if raw.score > 1 then Math.log(raw.score - 1) else if raw.score is 1 then 0 else -1)
			ratingExplanation: "LEN: #{Math.log(Statistics.normalizedLength(raw.body_html))}  TIME: #{Math.log((@times.parse - @times.submit) / 60)}  SCORE: #{if raw.score > 1 then Math.log(raw.score - 1) else if raw.score is 1 then 0 else -1}"