import Listing from './Listing'

export default class SubredditListing extends Listing
	constructor: (name) ->
		super()
		@href = '/' + name
		@name = 'r/' + name
		@display_name = name
		@is_pure = true
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				endpoint: 'r/' + name + '/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				endpoint: 'r/' + name + '/controversial'
				options: { t: sort[1..] }
			else
				endpoint: 'r/' + name + '/' + sort