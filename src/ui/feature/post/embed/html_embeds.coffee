export default (post) ->
	domain = if post.url.hostname.startsWith('www') then post.url.hostname[4..] else post.url.hostname
	switch domain
		when 'i.imgur.com'
			descriptor = post.url.pathname.split('/').at(-1).split('.')[0]
			return
				action_description: 'View (Imgur)'
				html: "<blockquote class='imgur-embed-pub' data-context='false' data-id='#{descriptor}'><a href='https://imgur.com/#{descriptor}'>#{post.url}</a></blockquote>"
				script: 'imgur'
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