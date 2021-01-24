import RedditList from '/src/objects/RedditList'
import RedditUser from '/src/objects/RedditUser'

idFromUrl = (url) ->
	switch
		when url.pathname.length < 4
			'me/home'
		when url.pathname.startsWith('/u/')
			url.pathname[3..].toLowerCase()
		when url.pathname.startsWith('/user/')
			url.pathname[6..].toLowerCase()
		else
			url.pathname[1..].toLowerCase()

export default class RedditFeed
	constructor: ({ id, fromUrl }) ->
		@id = id ? idFromUrl(fromUrl)
		[ userName, feedName, sort, itemCount ] = @id.split('/')
		@owner = new RedditUser(userName)
		@name = feedName ? 'overview'
		@order = sort ? if userName is 'r' then 'hot' else 'new'
		[ @orderclass, @ordervalue ] = @order.split('-')
		@multi = (userName is not 'r') or (feedName is 'all' or feedName is 'popular' or feedName.startsWith('u_'))
		@fragsize = itemCount ? 10
		@fragend = null
		@fragments = [
			@nextFragment
		]
		@href = '/' + @id
		@about = () =>
			endpoint = switch @owner.name
				when 'me' then ''
				when 'r' then '/r/' + @name + '/about'
				else '/user/' + @owner.name + '/about'
			Api.get(endpoint).then ({ data }) -> data
	nextFragment: () =>
		endpoint = switch @owner.name
			when 'me' then '/'
			when 'r' then '/r/' + @name
			else '/user/' + @owner.name + '/' + @name
		options =
			after: @fragend
			limit: @fragsize
			sort: @orderclass
			t: @ordervalue
		return Api.get(endpoint, options).then (rawListing) =>
			@fragend = rawListing?.data?.after
			return new RedditList(rawListing)