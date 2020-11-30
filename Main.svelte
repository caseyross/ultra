<template lang='pug'>

	main
		#feed-title
			h1 {state.page.name}
		#nav
			ol
				li
					a(href="{State.write(state, { page: { type: 'sm', name: '0/0' }, story: {} })}")
						kbd 1
						h1 frontpage
				li
					a(href='/sm/0/all')
						kbd 2
						h1 r/all
				li
					a(href='/sm/0/popular')
						kbd 3
						h1 r/popular
			ol
				li
					a(href='/u/me/saved')
						kbd 0
						h1 saved
			ol
				li
					button
						kbd ?
						h1 search
				li
					button
						kbd /
						h1 goto
			ul#my-subs
				+each('["earthporn", "fireemblem", "genshin_impact", "postprocessing", "singapore", "streetwear", "techwear"] as sub')
					li
						a.my-sub(href='/r/{sub}') {sub}
			ol
				li
					a(href='/message')
						.indicator-light
						kbd M
						h1 mail
				li
					a(href='/modmail')
						.indicator-light
						kbd ,
						h1 modmail
				li
					a(href='/modqueue')
						.indicator-light
						kbd .
						h1 modqueue
		+await('content.ABOUT')
			img#subreddit-icon
			+then('about')
				+if('about.community_icon')
					img#subreddit-icon(src='{about.community_icon}')
					+elseif('about.icon_img')
						img#subreddit-icon(src='{about.icon_img}')
					+else
						img#subreddit-icon
		
		menu#list-sort
			a(href='/{state.page.type}/{state.page.name}?sort=new')
				kbd ^1
				| New
			a(href='/{state.page.type}/{state.page.name}?sort=rising')
				kbd ^2
				| Rising
			a(href='/{state.page.type}/{state.page.name}?sort=hot')
				kbd ^3
				| Hot
			a(href='/{state.page.type}/{state.page.name}?sort=controversial')
				kbd ^4
				| Controversial
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=hour')
				kbd ^5
				| H
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=day')
				kbd ^6
				| D
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=week')
				kbd ^7
				| W
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=month')
				kbd ^8
				| M
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=year')
				kbd ^9
				| Y
			a(href='/{state.page.type}/{state.page.name}?sort=top&t=all')
				kbd ^0
				| A
		#list
			+await('content.PAGE')
				+then('objects')
					SubredditFeed(objects='{objects}' show_flair!='{state.page.type === "r"}')
				+catch('error')
					.error-tag ERROR LOADING FEED
					.error-message {error}
		+await('content.PAGE')
			+then('stories')
				+if('stories.some(x => state.story.id === x.id)')
					Post(post!='{stories.find(x => state.story.id === x.id)}')
					Comments(post!='{stories.find(x => state.story.id === x.id)}')
					+else
						#list-description
							+await('content.ABOUT then about')
								img(src='{about.banner_background_image || about.banner_img}')
								article
									+html('about.description_html')
								+catch('error')
									article {error}
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
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
		grid-template-areas 'story-meta feed-meta comments-sort' 'object list comments'
		overflow hidden
		background #222
		color white
		font 400 1.5rem/1 'Iosevka Aile', sans-serif
	#feed-title
		grid-area feed-meta
	#story-title
		grid-area story-meta
	#nav
		grid-area nav
		display none
		flex-flow column nowrap
		border-right 1px dotted
		ol
		ul
			padding 0
			list-style none
		a
		button
			display flex
			align-items center
		h1
			margin 0
			color rgba(0,0,0,0.5)
	.indicator-light
		position absolute
		left 0
		width 1rem
		height 1rem
		background black
	button
		color gray
		& ~ &
			margin-left 2rem
		a
			color inherit
			text-decoration none
	#my-subs
		flex 1
	#list-sort
		display none
		grid-area list-sort
		padding-left 5rem
		padding-top 1rem
	#list
		grid-area list
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
	export content = {}

	import Comments from '/comp/Comments'
	import Post from '/comp/Post'
	import SubredditFeed from '/comp/SubredditFeed'

	document.keyboard_shortcuts.Digit1 =
		n: 'Navigation: Frontpage'
	document.keyboard_shortcuts.Digit2 =
		n: 'Navigation: Popular'
	document.keyboard_shortcuts.Digit0 =
		n: 'Navigation: Saved'
	document.keyboard_shortcuts.Slash =
		n: 'Navigation: Goto...'
		sn: 'Navigation: Search'

</script>