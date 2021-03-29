import Listing from '../Listing'

export default class Subreddit extends Listing
	constructor: (name) ->
		super()
		@id = 'r/' + name
		@href = '/' + name
		@display_name = name
		@page_config = (sort = 'hot') -> switch sort
			when 'hour', 'day', 'week', 'month', 'year', 'all'
				url: '/r/' + name + '/top'
				options: { t: sort }
			when 'chour', 'cday', 'cweek', 'cmonth', 'cyear', 'call'
				url: '/r/' + name + '/controversial'
				options: { t: sort[1..] }
			else
				url: '/r/' + name + '/' + sort
		@profile_config = () ->
			url: '/r/' + name + '/about'