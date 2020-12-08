<template lang='pug'>

	+each('[visitors, residents] as slice')
		ol
			+each('slice as ITEM')
				li
					+await('ITEM')
						p ---loading
						+then('item')
							+if('item instanceof Post')
								FeedPost(post='{item}')
								+elseif('item instanceof Comment')
									p ---comment
								+elseif('item instanceof Message')
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

	import FeedPost from '/comp/FeedPost'
	import Comment from '/objects/Comment'
	import Message from '/objects/Message'
	import Post from '/objects/Post'

	export visitors = []
	export residents = []

</script>