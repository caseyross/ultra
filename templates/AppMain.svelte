<template lang='pug'>

	main
		+await('state.SELECTED_ITEM')
			+then('item')
				+if('item')
					#item-actions
					#item-title
						h3 {item.title}
					#item-content
						PostContent(content='{item.content}')
						PostComments(comments='{item.comments}')
					+else
						#listing-description
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

</template><style>

	main
		height 100%
		overflow auto
	#item-actions
		height 5rem
	#item-title
		height 5rem
	#item-content
		display flex

</style><script>

	export state = {}

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