import Listing from './Listing'

export default class FrontpageListing extends Listing
	constructor: () ->
		super()
		@href = '/'
		@name = 'frontpage'
		@display_name = 'frontpage'
		@page_config = (sort = 'best') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				endpoint: 'top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				endpoint: 'controversial'
				options: { t: sort[1..] }
			else
				endpoint: sort