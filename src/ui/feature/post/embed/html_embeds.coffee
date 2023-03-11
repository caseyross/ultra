export default (post) -> switch (if post.url?.hostname.startsWith('www') then post.url?.hostname[4..] else post.url?.hostname)
	when 'mobile.twitter.com'
		if post.media_embed?.content
			action_description: 'Read'
			html: post.media_embed.content
		else
			null
	when 'twitter.com'
		if post.media_embed?.content
			action_description: 'Read'
			html: post.media_embed.content
		else
			null
	else
		null