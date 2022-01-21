import * as API from './API.coffee'

export default {

	DOWNLOAD_REMOTE_DATA: () ->
		new Intent('START_DOWNLOAD')
		.then (data) ->
			new Intent('ORGANIZE_DOWNLOADED_DATA')

	START_DOWNLOAD: () ->
		return
			loading:
				[id]: true

	ORGANIZE_DOWNLOADED_DATA: (data) ->
		return
			loading:
				[id]: false
			objects:
				[id]: object
			vintage:
				[id]: Date.now()

	'Load URL Internally': (url) ->
		pageFragment = url.hash[1..] # The hash starts with '#'.
		pathSegments = url.pathname.split('/')[1..] # The pathname starts with a slash, so the first element from split() is always''.
		queryParams = new URLSearchParams url.search
		# Check prefixed paths
		switch pathSegments[0]
			when 'c'
				route: 'COMMENT'
				data:
					id: pathSegments[1].toCommentId()
			when 'p'
				route: 'POST'
				data:
					id: pathSegments[1].toPostId()
					sort: pageFragment
					stream: switch
						when queryParams.has 'r'
							type: 'BOARD'
							name: queryParams.get 'r'
						when queryParams.has 'u'
							type: 'USER'
							name: queryParams.get 'u'
						else
							null
			when 'r'
				route: 'BOARD'
				data:
					name: pathSegments[1].toBoardName()
					sort: pageFragment
			when 'u'
				route: 'USER'
				data:
					name: pathSegments[1].toUserName()
					sort: pageFragment
			else
				# Check non-prefixed paths
				switch pathSegments[0]
					when ''
					else
						route: 'BOARD'
						data:
							name: pathSegments[0].toBoardName()
							sort: pageFragment
		new Intent('DOWNLOAD_DATA', 
		for post in page
			fetchPostComments(post.id)
		fetchSubredditInfo()
		fetchSubredditEmojis()
		{
			routing:
				route: ''
		}
	'Upvote Submission': (id, newScore) ->
		API.sendUpvote(id)
		{
			objects:
				[id]:
					likes: true
					score: newScore
					ups: newScore
		}
	'Toggle Global Navigation Visibility': (isVisible) ->
		{
			toggled:
				navigation: Boolean(isVisible)
		}
	'Update Metrics': ->
		{
			metrics:
				currentRatelimitUsage: getRatelimitStatus().used
		}
}