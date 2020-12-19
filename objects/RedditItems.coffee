import RedditAward from '/objects/RedditAward'
import RedditComment from '/objects/RedditComment'
import RedditMessage from '/objects/RedditMessage'
import RedditMoreComments from '/objects/RedditMoreComments'
import RedditPost from '/objects/RedditPost'
import RedditUser from '/objects/RedditUser'
import RedditSubreddit from '/objects/RedditSubreddit'

export default class RedditItems
	constructor: (raw) ->
		return [] unless raw?.kind is 'Listing' and raw?.data?.children instanceof Array
		return raw.data.children.map (child) ->
			switch child.kind
				when 'Listing'
					new this(child.data)
				when 't1'
					new RedditComment(child.data)
				when 't2'
					new RedditUser(child.data)
				when 't3'
					new RedditPost(child.data)
				when 't4'
					new RedditMessage(child.data)
				when 't5'
					new RedditSubreddit(child.data)
				when 't6'
					new RedditAward(child.data)
				when 'more'
					new RedditMoreComments(child.data)