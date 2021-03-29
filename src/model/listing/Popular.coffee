import Listing from '../Listing'

export default class Popular extends Listing
	constructor: () ->
		super()
		@id = 'popular'
		@href = '/popular'
		@display_name = 'Popular'
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				url: '/r/popular/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				url: '/r/popular/controversial'
				options: { t: sort[1..] }
			else
				url: '/r/popular/' + sort