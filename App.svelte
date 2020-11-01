<template lang='pug'>
	svelte:head
		+await('page.ABOUT')
			title {page.type + '/' + page.name}
			+then('about')
				title {about.title}
	main
		#nav
			ol
				li
					a(href='/')
						kbd 1
						h1 FRONTPAGE
				li
					a(href='/r/popular')
						kbd 2
						h1 POPULAR
				li
					button
						kbd ?
						h1 SEARCH
				li
					a(href='/u/me/saved')
						kbd 0
						h1 SAVED
				li
					button
						kbd /
						h1 GOTO
			ul#my-subs
				li
					a(href='/r/singapore')
						h4 singapore
			ol
				li
					a(href='/message')
						.indicator-light
						kbd M
						h1 MAIL
				li
					a(href='/modmail')
						.indicator-light
						kbd ,
						h1 MODMAIL
				li
					a(href='/modqueue')
						.indicator-light
						kbd .
						h1 MODQUEUE
		+await('page.ABOUT')
			img#subreddit-icon
			+then('about')
				+if('about.community_icon')
					img#subreddit-icon(src='{about.community_icon}')
					+elseif('about.icon_img')
						img#subreddit-icon(src='{about.icon_img}')
					+else
						img#subreddit-icon
		menu.tabs#list-sort
			button
				kbd ^1
				| new
			button
				kbd ^2
				| rising
			button
				kbd ^3
				| hot
			button
				kbd ^4
				| contro.
			button
				kbd ^5
				| hour
			button
				kbd ^6
				| day
			button
				kbd ^7
				| week
			button
				kbd ^8
				| month
			button
				kbd ^9
				| year
			button
				kbd ^0
				| all
		List(LIST='{page.STORIES}')
		+await('OBJECT')
			#list-description
				+await('page.ABOUT then about')
					img(src='{about.banner_background_image || about.banner_img}')
					article
						+html('about.description_html')
					+catch('error')
						article {error}
			+then('object')
				Post(post='{object}')
				Comments(post='{object}')
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
		menu#comments-sort
			button
				kbd 1
				| newest
			button
				kbd 1
				| score
			button
				kbd 1
				| controversiality
			button
				kbd 1
				| op replies
			button
				kbd 1
				| oldest
			button
				kbd 1
				| reddit default
		button#minimap-hat
		Menu
		+if('inspect')
			#inspect-overlay
				Inspector(key='page' value='{page}')
				Inspector(key='story' value='{story}')
</template>

<style>
	main
		height 100%
		display grid
		grid-template-columns 192px 1fr 16px 640px 640px
		grid-template-rows 5rem 1fr 4rem
		grid-template-areas 'nav list-sort . object comments-sort' 'nav list . object comments' 'nav list . object comments'
		overflow hidden
		background wheat
		color black
		font 300 14px monospace
	#nav
		grid-area nav
		display flex
		flex-flow column nowrap
		border-right 1px dotted
		ol
			padding 0
			list-style none
		li
			opacity 0.5
			&:hover
				opacity 1
		a
		button
			display flex
			align-items baseline
		h1
			margin 0
			color rgba(0,0,0,0.5)
	.indicator-light
		position absolute
		left 0
		width 1rem
		height 1rem
		background black
	a
		color inherit
		text-decoration none
	button
		color gray
		& ~ &
			margin-left 2rem
		a
			color inherit
			text-decoration none
	#my-subs
		flex 1
	#list-description
		grid-area object
		height 100%
		overflow auto
		img
			width 100%
			max-height 288px
			object-fit cover
			margin-bottom 16px
	#list-sort
		grid-area list-sort
		display flex
		align-items flex-end
		button
			margin 0
			border 1px dotted
			border-width 0 1px 1px 0
	#list-actions
		grid-area list-actions
		padding-left 1rem
		display flex
		align-items center
	#object-actions
		grid-area object-actions
		display flex
		align-items center
	#comments-sort
		grid-area comments-sort
		padding-left 1rem
		display flex
		align-items flex-end
		button
			margin 0
			border 1px dotted
			border-width 0 0 1px 1px
	#comments-actions
		grid-area comments-actions
		padding-left 1rem
		display flex
		align-items center
	#minimap-hat
		position fixed
		top 0
		right 0
		width 4rem
		height 4rem
		background black
	#subreddit-icon
		display none
	#inspect-overlay
		position fixed
		top 0
		width 100%
		height 100%
		padding 1% 0
		overflow auto
		background #fed
</style>

<script>
	export page = {}
	export story = {}
	OBJECT = new Promise (f, r) -> {}

	import Comments from '/comp/comments.svelte'
	import List from '/comp/list.svelte'
	import Inspector from '/comp/inspector.svelte'
	import Menu from '/comp/menu.svelte'
	import Post from '/comp/post.svelte'

	inspect = off
	
	document.keyboard_shortcuts.Digit1 =
		n: 'Navigation: Frontpage'
	document.keyboard_shortcuts.Digit2 =
		n: 'Navigation: Popular'
	document.keyboard_shortcuts.Digit0 =
		n: 'Navigation: Saved'
	document.keyboard_shortcuts.Slash =
		n: 'Navigation: Goto...'
		sn: 'Navigation: Search'
	document.keyboard_shortcuts.Backquote =
		n: 'Toggle Inspector'
		d: () => inspect = !inspect
</script>