sorts = [
	'new', 'rising', 'hot', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all'
]

export default class RedditFeed
	constructor: (url, currentFeed) ->
		[ empty, type, name, selections ] = url.pathname.split('/')
		if selections
			## ---load selections into current feed if possible ##
			if currentFeed
				## ---if a feed state already exists, maintain that state as much as possible... ##
				feed = { ...currentFeed }
			else
				## ---...if not, generate a fresh state (effectively, load a new feed with the selections visiting). ##
				feed = new RedditFeed({ ...url, pathname: [empty, type, name].join('/') })
			## ---is item a resident of current feed? ##
			[ itemId, commentId, commentContext ] = selections.split('-')
			residentsIndex = feed.idMap[itemId]
			if residentsIndex?
				## ---yes, load item from residents ##
				ITEM = feed.residents[residentsIndex]
				## ---load full comments for item ##
				Reddit.FEED_POST({ id: itemId, commentId: commentId, commentContext: commentContext })
					.then (post) ->
						feed.residents[residentsIndex] = Promise.resolve post
						feed.SELECTED = feed.residents[residentsIndex]
			else
				## ---no, load item as a visitor ##
				ITEM = Reddit.FEED_POST({ id: itemId, commentId: commentId, commentContext: commentContext })
				feed.visitors = [ITEM]
			feed.SELECTED = ITEM
			return feed
		else
			## ---load new feed ##
			@type = if type then type else 'r'
			@name = name ? ''
			@id = @type + '/' + @name
			@sort = if @id is 'r/' then 'best' else 'hot'
			for [k, v] from (new URLSearchParams(url.search))
				if k is 'search'
					@sort = 'search-' + v
					break
				if sorts.includes(k) then @sort = k
			@idMap = {}
			@visitors = []
			@residents = Reddit.FEED_SLICE({ type: @type, name: @name, sort: @sort, idMap: @idMap })
			@meta =
				ABOUT: Reddit.FEED_METADATA({ type: @type, name: @name })
			@SELECTED = Promise.resolve null
			## ---no explicit return, run the constructor ##