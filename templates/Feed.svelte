<template lang='pug'>

	ol
		+each('state.listingItems as ITEM')
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
		width 100%
		margin 0
		padding 0
		list-style none
		display flex
		flex-flow column nowrap

</style><script>
	
	export state = {}

	import RedditComment from '/objects/RedditComment'
	import RedditMessage from '/objects/RedditMessage'
	import RedditPost from '/objects/RedditPost'
	import Comment from '/templates/Comment'
	import Post from '/templates/Post'

</script>