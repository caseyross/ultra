import Listing from './Listing'

export default class PopularListing extends Listing
	constructor: () ->
		super()
		@href = '/popular'
		@name = 'popular'
		@display_name = 'r/popular'
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				endpoint: 'r/popular/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				endpoint: 'r/popular/controversial'
				options: { t: sort[1..] }
			else
				endpoint: 'r/popular/' + sort