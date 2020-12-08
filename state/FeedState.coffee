rankings = [
	'new', 'rising', 'hot', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all'
]

export default class FeedState
	constructor: (url, currentFeedState) ->
		[ empty, type, name, selections ] = url.pathname.split('/')
		if selections
			## ---load selections into current feed if possible ##
			if currentFeedState
				## ---if a feed state already exists, maintain that state as much as possible... ##
				feedState = { ...currentFeedState }
			else
				## ---...if not, generate a fresh state (effectively, load a new feed with the selections visiting). ##
				feedState = new FeedState({ ...url, pathname: [empty, type, name].join('/') })
			## ---is item a resident of current feed? ##
			[ itemId, commentId, commentContext ] = selections.split('-')
			residentsIndex = feedState.idMap[itemId]
			if residentsIndex?
				## ---yes, load item from residents ##
				ITEM = feedState.residents[residentsIndex]
				## ---load full comments for item ##
				Reddit.FEED_POST({ id: itemId, commentId: commentId, commentContext: commentContext })
					.then (post) ->
						feedState.residents[residentsIndex] = Promise.resolve post
						feedState.SELECTED = feedState.residents[residentsIndex]
			else
				## ---no, load item as a visitor ##
				ITEM = Reddit.FEED_POST({ id: itemId, commentId: commentId, commentContext: commentContext })
				feedState.visitors = [ITEM]
			feedState.SELECTED = ITEM
			return feedState
		else
			## ---load new feed ##
			@type = if type then type else 'r'
			@name = name ? ''
			@id = @type + '/' + @name
			@ranking = if @id is 'r/' then 'best' else 'hot'
			for [k, v] from (new URLSearchParams(url.search))
				if k is 'search'
					@ranking = 'search-' + v
					break
				if rankings.includes(k) then @ranking = k
			@idMap = {}
			@visitors = []
			@residents = Reddit.FEED_SLICE({ type: @type, name: @name, ranking: @ranking, idMap: @idMap })
			@meta =
				ABOUT: Reddit.FEED_METADATA({ type: @type, name: @name })
			@SELECTED = Promise.resolve null
			## ---no explicit return, run the constructor ##