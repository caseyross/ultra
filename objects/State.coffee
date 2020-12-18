sorts = [
	'new', 'rising', 'hot', 'top-hour', 'top-day', 'top-week', 'top-month', 'top-year', 'top-all', 'controversial-hour', 'controversial-day', 'controversial-week', 'controversial-month', 'controversial-year', 'controversial-all'
]

export default class State
	constructor: (url, baseState) ->
		[ nothing, listingType, listingName, selections ] = url.pathname.split('/')
		if selections
			# Are we building upon a previous state?
			if baseState
				# Yes.
				newState = { ...baseState }
			else
				# No, start fresh.
				newState = new State({ ...url, pathname: [nothing, listingType, listingName].join('/') })
			[ itemId, commentId, commentContext ] = selections.split('-')
			itemIndex = newState.idMap[itemId]
			# Is data for the desired item already present?
			if itemIndex?
				# Yes, it must be from the current listing.
				DESIRED_ITEM = newState.listingItems[itemIndex]
				# Fetch the comments for the item.
				Reddit.POST({ id: itemId, commentId, commentContext })
					.then (post) ->
						newState.listingItems[itemIndex] = Promise.resolve post
						newState.SELECTED_ITEM = newState.listingItems[itemIndex]
			else
				# No, item must be foreign; fetch the whole item now.
				DESIRED_ITEM = Reddit.POST({ id: itemId, commentId: commentId, commentContext: commentContext })
				newState.foreignItems = [DESIRED_ITEM]
			# Make the selection.
			newState.SELECTED_ITEM = DESIRED_ITEM
			# Return the new object instead of running the constructor.
			return newState
		else
			# Generate a fresh state.
			@idMap = {}
			@listingId = (if listingType then listingType else 'r') + '/' + (listingName ? '')
			@listingSort = if @listingId is 'r/' then 'best' else 'hot'
			for [k, v] from (new URLSearchParams(url.search))
				if k is 'search'
					@listingSort = 'search-' + v
					break
				if sorts.includes(k) then @listingSort = k
			@listingItems = Reddit.LISTING_SLICE({ id: @listingId, sort: @listingSort, idMap: @idMap })
			@listingMetadata =
				ABOUT: Reddit.LISTING_ABOUT({ id: @listingId })
			@foreignItems = []
			@SELECTED_ITEM = Promise.resolve null