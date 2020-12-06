rankings = [
	'new', 'rising', 'hot', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all'
]

export default class FeedState
	constructor: (url = window.location) ->
		[ _, @type, @name, @selection ] = url.pathname.split('/')
		@type = if @type then @type else 'r'
		@name = @name ? ''
		@id = @type + '/' + @name
		@ranking = if @id is 'r/' then 'best' else 'hot'
		for [k, v] from (new URLSearchParams(url.search))
			if k is 'search'
				@ranking = 'search-' + v
				break
			if rankings.includes(k) then @ranking = k
		@ABOUT = Promise.resolve null
		@ITEMS = Promise.resolve []
		@PERMALINKED_ITEM = Promise.resolve null
	sync: (prevFeedState) =>
		console.log(prevFeedState)
		if prevFeedState
			if @id is prevFeedState.id and @ranking is prevFeedState.ranking
				return
		else
			if @selection
				[ itemId, commentId, commentContext ] = @selection.split('-')
				@PERMALINKED_ITEM = Reddit.POST({ id: itemId, commentId: commentId, commentContext: commentContext })
		@ABOUT = Reddit.FEED_METADATA({ type: @type, name: @name })
		@ITEMS = Reddit.FEED_SLICE({ type: @type, name: @name, ranking: @ranking })