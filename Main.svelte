<template lang='pug'>

	main
		#feed-title
			h1 {state.feed.name || 'front page'}
		+await('state.feed.meta.ABOUT')
			img#subreddit-icon
			+then('about')
				+if('about')
					+if('about.community_icon')
						img#subreddit-icon(src='{about.community_icon}')
						+elseif('about.icon_img')
							img#subreddit-icon(src='{about.icon_img}')
						+else
							img#subreddit-icon
		#feed
			Feed(visitors='{state.feed.visitors}' residents='{state.feed.residents}')
		+await('state.feed.SELECTED')
			+then('item')
				+if('item')
					PostContent(content='{item.content}')
					+else
						#list-description
							+await('state.feed.meta.ABOUT then about')
								+if('about')
									img(src='{about.banner_background_image || about.banner_img}')
									article
										+html('about.description_html')
								+catch('error')
									article {error}
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
		+await('state.feed.SELECTED')
			+then('item')
				+if('item')
					Comments(comments='{item.comments}')
		menu#comments-sort
			a
				kbd 1
				| default
			a
				kbd 1
				| old
			a
				kbd 1
				| new
			a
				kbd 1
				| rating
			a
				kbd 1
				| controversial
			a
				kbd 1
				| op replies
		button#minimap-hat

</template><style>

	main
		height 100%
		display grid
		grid-template-columns 1fr 1fr 1fr
		grid-template-rows 10rem 1fr
		grid-template-areas 'item-meta feed-meta comments-sort' 'item feed comments'
		overflow hidden
		background #222
		color white
		font 400 1.5rem/1 'Iosevka Aile', sans-serif
	#feed-title
		grid-area feed-meta
	button
		color gray
		& ~ &
			margin-left 2rem
		a
			color inherit
			text-decoration none
	#feed
		grid-area feed
		overflow auto
		will-change transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
	#comments-sort
		grid-area comments-sort
		padding-left 1rem
		display flex
		align-items flex-end
		button
			margin 0
			border 1px dotted
			border-width 0 0 1px 1px
	#minimap-hat
		position fixed
		top 0
		right 0
		width 4rem
		height 4rem
		background black
	#subreddit-icon
		display none

</style><script>

	export state = {}

	import Comments from '/comp/Comments'
	import Feed from '/comp/Feed'
	import PostContent from '/comp/PostContent'

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