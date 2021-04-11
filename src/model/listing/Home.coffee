import Listing from '../Listing'

export default class Home extends Listing
	constructor: () ->
		super()
		@id = 'home'
		@href = '/'
		@display_name = 'Frontpage'
		@page_config = (sort = 'best') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				url: '/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				url: '/controversial'
				options: { t: sort[1..] }
			else
				url: '/' + sort