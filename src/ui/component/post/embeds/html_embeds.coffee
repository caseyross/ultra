export default (post) ->

	domain = if post.url.hostname.startsWith('www') then post.url.hostname[4..] else post.url.hostname
	
	switch domain
		when 'mobile.twitter.com'
			action_description: 'Read (Twitter)'
			html: "<blockquote class='twitter-tweet' data-dnt='true'><a href=#{post.url}>#{post.url}</a></blockquote>"
			script: 'twitter'
		when 'twitter.com'
			action_description: 'Read (Twitter)'
			html: "<blockquote class='twitter-tweet' data-dnt='true'><a href=#{post.url}>#{post.url}</a></blockquote>"
			script: 'twitter'
		else
			null