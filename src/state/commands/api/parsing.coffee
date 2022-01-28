parseListing = ({ kind, children }) ->
	if kind == 'Listing' and children instanceof Array
		for child in children
			parseThing(child)

# Yes, reddit actually calls this data structure a "Thing". (Sigh...)
parseThing = ({ kind, data }) ->
	switch kind
		when 't1' # comment
			if data.replies?.length > 0
				if data.replies.last().kind is 'more' # lazily-loaded comments
					more = data.replies.pop()
					if more.depth < 10
						data.moreReplies = more.data.children.map((replyId) -> replyId.toCommentId())
					else
						# At comment depth 10, "more" objects stop returning IDs of comment replies. In the official UI, you must load a new page to see comments below this depth.
						data.repliesContinue = true
					parseThing(reply)
				for reply in data.replies
				data.replies = data.replies.map((reply) -> reply.data.id.toCommentId())
			objects[data.id.toCommentId()] = data
		when 't2' # user
			objects[data.subreddit.id.toSubredditId()] = data.subreddit # Each user has a personal subreddit (often referred to as "your profile").
			data.subreddit = data.subreddit.id.toSubredditId()
			objects[data.id.toUserId()] = data
		when 't3' # post
			if data.sr_detail
				objects[data.sr_detail.id.toSubredditId()] = data.sr_detail
			# Note that post data does NOT come with comments attached. These need to be linked up at a higher level.
			objects[data.id.toPostId()] = data
		when 't4' # private message
			data.longId = data.id.toMessageId()
			data.shortId = data.id.toShortId()
			delete data.id
			objects[data.longId] = data
		when 't5' # subreddit
			data.longId = data.id.toSubredditId()
			data.shortId = data.id.toShortId()
			delete data.id
			objects[data.longId] = data
		when 't6' # award
			data.longId = data.id.toAwardId()
			data.shortId = data.id.toShortId()
			delete data.id
			objects[data.longId] = data