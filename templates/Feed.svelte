<template lang='pug'>

	+each('[visitors, residents] as slice')
		ol
			+each('slice as ITEM')
				li
					+await('ITEM')
						p ---loading
						+then('item')
							+if('item instanceof RedditPost')
								Post(post='{item}')
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

</style><script>

	import RedditComment from '/objects/RedditComment'
	import RedditMessage from '/objects/RedditMessage'
	import RedditPost from '/objects/RedditPost'
	import Comment from '/templates/Comment'
	import Post from '/templates/Post'

	export visitors = []
	export residents = []

</script>