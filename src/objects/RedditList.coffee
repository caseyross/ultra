import RedditAward from '/src/objects/RedditAward'
import RedditComment from '/src/objects/RedditComment'
import RedditFeed from '/src/objects/RedditFeed'
import RedditMessage from '/src/objects/RedditMessage'
import RedditMoreComments from '/src/objects/RedditMoreComments'
import RedditPost from '/src/objects/RedditPost'
import RedditUser from '/src/objects/RedditUser'

export default class RedditList
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
					new RedditFeed(child.data)
				when 't6'
					new RedditAward(child.data)
				when 'more'
					new RedditMoreComments(child.data)