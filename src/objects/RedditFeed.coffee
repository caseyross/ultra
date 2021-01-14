import RedditList from '/src/objects/RedditList'
import RedditUser from '/src/objects/RedditUser'

export default class RedditFeed
	constructor: (urlPath) ->
		if urlPath.length < 4
			@id = '/me/home/best'
		else if urlPath.startsWith('/u/')
			@id = urlPath[2..].toLowerCase()
		else if urlPath.startsWith('/user/')
			@id = urlPath[4..].toLowerCase()
		else
			@id = urlPath.toLowerCase()
		[ _, seg1, seg2, seg3, seg4 ] = @id.split('/')
		@owner = new RedditUser(seg1)
		@name = seg2 ? 'overview'
		@order = seg3 ? if @owner.name is 'r' then 'hot' else 'new'
		[ @orderclass, @ordervalue ] = @order.split('-')
		@fragsize = seg4 ? 10
		@fragend = null
		@fragments = [
			@nextFragment
		]
		@sidebar = () ->
			endpoint = switch @owner.name
				when 'me' then ''
				when 'r' then '/r/' + @name + '/about'
				else '/user/' + @owner.name + '/about'
			Api.get(endpoint).then ({ data }) -> data
	nextFragment: () =>
		endpoint = switch @owner.name
			when 'me' then '/'
			when 'r' then @id
			else '/user/' + @owner.name + '/' + @name
		options =
			after: @fragend
			limit: @fragsize
			sort: @orderclass
			t: @ordervalue
		return Api.get(endpoint, options).then (rawListing) =>
			@fragend = rawListing?.data?.after
			return new RedditList(rawListing)