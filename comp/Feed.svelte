<template lang='pug'>
	
	+await('PERMALINKED_ITEM')
		+then('permalinked_item')
			+if('permalinked_item')
				FeedPost(post='{permalinked_item}')
	+await('ITEMS')
		+then('items')
			ol
				+each('items as item')
					li(tabindex=0)
						FeedPost(post='{item}')
		+catch('error')
			.error-tag ERROR LOADING FEED
			.error-message {error}

</template><style>

	ol
		height 100%
		overflow auto
		margin 0
		padding 0
		will-change transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		list-style none

</style><script>

	import FeedPost from '/comp/FeedPost'

	export ITEMS = Promise.resolve([])
	export PERMALINKED_ITEM = new Promise () -> {}

</script>