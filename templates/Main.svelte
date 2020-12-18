<template lang='pug'>

	main
		+await('state.SELECTED_ITEM')
			+then('item')
				+if('item')
					PostContent(content='{item.content}')
					+else
						#list-description
							+await('state.listingMetadata.ABOUT then about')
								+if('about')
									img(src='{about.banner_background_image || about.banner_img}')
									article
										+html('about.description_html')
								+catch('error')
									article {error}
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
		Feed(state='{state}')
		+await('state.SELECTED_ITEM')
			+then('item')
				+if('item')
					PostComments(comments='{item.comments}')

</template><style>

	main
		display grid
		grid-template-columns 1fr 1fr 1fr
		height 100%
		overflow hidden
		background #222
		color white
		font 300 1.5rem/1.5 'Iosevka Aile', sans-serif

</style><script>

	export state = {}

	import Feed from '/templates/Feed'
	import PostComments from '/templates/PostComments'
	import PostContent from '/templates/PostContent'

	document.keyboardShortcuts.Digit1 =
		n: 'Navigation: Frontpage'
	document.keyboardShortcuts.Digit2 =
		n: 'Navigation: Popular'
	document.keyboardShortcuts.Digit0 =
		n: 'Navigation: Saved'
	document.keyboardShortcuts.Slash =
		n: 'Navigation: Goto...'
		sn: 'Navigation: Search'

</script>