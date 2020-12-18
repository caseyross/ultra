<template lang='pug'>

	h1 {state.listingId || 'frontpage'}
	+await('state.listingMetadata.ABOUT')
		img#subreddit-icon
		+then('about')
			+if('about')
				+if('about.community_icon')
					img#subreddit-icon(src='{about.community_icon}')
					+elseif('about.icon_img')
						img#subreddit-icon(src='{about.icon_img}')
					+else
						img#subreddit-icon
	+each('[state.listingItems, state.foreignItems] as items')
		ol
			+each('items as ITEM')
				li
					+await('ITEM')
						p ---loading
						+then('item')
							a(href='{item.permalink}')
								+if('item instanceof RedditPost')
									Post(post='{item}' showOrigin='{state.listingId !== item.listingId}')
									+elseif('item instanceof RedditComment')
										Comment(comment='{item}')
									+elseif('item instanceof RedditMessage')
										p ---message
									+else
										p ---unknown item
						+catch('error')
							.error-tag ERROR LOADING FEED
							.error-message {error}

</template><style>

	ol
		margin 0
		padding 0
		list-style none
	#subreddit-icon
		display none

</style><script>
	
	export state = {}

	import RedditComment from '/objects/RedditComment'
	import RedditMessage from '/objects/RedditMessage'
	import RedditPost from '/objects/RedditPost'
	import Comment from '/templates/Comment'
	import Post from '/templates/Post'

</script>