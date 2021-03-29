import Listing from '../Listing'

export default class All extends Listing
	constructor: () ->
		super()
		@id = 'all'
		@href = '/all'
		@display_name = 'All'
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				url: '/r/all/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				url: '/r/all/controversial'
				options: { t: sort[1..] }
			else
				url: '/r/all/' + sort