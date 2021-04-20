import ThingList from '../thing/ThingList'

export default class Listing
	constructor: ->
		@href = ''
		@name = ''
		@display_name = ''
		@page_config = ->
			endpoint: ''
			options: {}
	PAGE: ({ after, seen, limit, sort }) =>
		new LazyPromise => # PERF: May be faster to remove laziness, since this always needs to run ASAP after page load anyway
			API.get @page_config(sort).endpoint,
				{
					after: after or '',
					count: seen or 0,
					limit: limit or 25,
					...@page_config(sort).options
				} 
			.then (data) ->
				next_after: data.data.after
				used_sort: sort
				used_limit: limit
				things: new ThingList(data)