import Listing from './Listing'

export default class AllListing extends Listing
	constructor: () ->
		super()
		@href = '/all'
		@name = 'all'
		@display_name = 'r/all'
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				endpoint: 'r/all/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				endpoint: 'r/all/controversial'
				options: { t: sort[1..] }
			else
				endpoint: 'r/all/' + sort