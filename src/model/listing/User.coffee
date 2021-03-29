import Listing from '../Listing'

export default class User extends Listing
	constructor: (name) ->
		super()
		@id = 'u/' + name
		@href = '/u/' + name
		@display_name = name
		@page_config = (sort = 'new') ->
			url: '/user/' + name + '/overview'
			options: switch sort
				when 'hour', 'day', 'week', 'month', 'year', 'all'
					{ sort: 'top', t: sort }
				when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
					{ sort: 'controversial', t: sort[1..] }
				else
					{ sort: sort }
		@profile_config = () ->
			url: '/user/' + name + '/about'