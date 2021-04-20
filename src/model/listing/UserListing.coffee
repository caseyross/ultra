import Listing from './Listing'

export default class UserListing extends Listing
	constructor: (name) ->
		super()
		@href = '/u/' + name
		@name = 'u/' + name
		@display_name = name
		@page_config = (sort = 'new') ->
			endpoint: 'user/' + name + '/overview'
			options: switch sort
				when 'hour', 'day', 'week', 'month', 'year', 'all'
					{ sort: 'top', t: sort }
				when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
					{ sort: 'controversial', t: sort[1..] }
				else
					{ sort: sort }