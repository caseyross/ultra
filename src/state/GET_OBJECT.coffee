export default (id) ->

	[type, shortId] = id.split('_')
	switch type
		
		when 't1'
		when 't3'
		when 't4'
		when 't6'
		when 'morecomments'
		when 'aboutuser'
		when 'aboutsubreddit'
		when 'widgets'
		when 'emojis'
		when 'slice'
			[name, sort, count] = shortId.split(':')