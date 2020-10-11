<template lang='pug'>
	svelte:head
		+await('data.LIST_DESCRIPTION')
			title {state.list_id}
			+then('description')
				title {description.title}
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
					a(href='/')
						kbd ?
						h1 SEARCH
				li
					a(href='/')
						kbd 0
						h1 SAVED
				li
					a(href='/')
						kbd /
						h1 GOTO
			ul#my-subs
				li
					a(href='/r/singapore')
						h4 singapore
			ol
				li
					a(href='/')
						.indicator-light
						kbd M
						h1 MAIL
				li
					a(href='/r/all')
						.indicator-light
						kbd ,
						h1 MODMAIL
				li
					a(href='/r/all')
						.indicator-light
						kbd .
						h1 MODQUEUE
		+await('data.LIST_DESCRIPTION')
			img#subreddit-icon
			+then('description')
				+if('description.community_icon')
					img#subreddit-icon(src='{description.community_icon}')
					+elseif('description.icon_img')
						img#subreddit-icon(src='{description.icon_img}')
					+else
						img#subreddit-icon(src='{img_reddit_logo}')
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
		List(LIST='{data.LIST}' choice='{state.object_id}' f_choose='{f_choose_object}' )
		menu#list-actions
			button
				kbd W
				| previous item
			button
				kbd S
				| next item
			button
				kbd +
				| submit post
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
		+await('data.OBJECT')
			#list-description
				+await('data.LIST_DESCRIPTION then description')
					img(src='{description.banner_background_image || description.banner_img}')
					article
						+html('description.description_html')
					+catch('error')
						article {error}
			+then('object')
				Post(post='{object}')
				Comments(post='{object}')
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
		menu#comments-actions
			button
				kbd C
				| goto next top-level comment
			button
				kbd R
				| reply with top-level comment
		button#minimap-hat
		Menu
		+if('state.inspect')
			#inspector
				Inspector(key='state' value='{state}')
				Inspector(key='data' value='{data}')
</template>

<style>
	main
		height 100%
		display grid
		grid-template-columns 192px 1fr 16px 640px 640px
		grid-template-rows 5rem 1fr 4rem
		grid-template-areas 'nav list-sort . object comments-sort' 'nav list . object comments' 'nav list-actions . object comments-actions'
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
			display flex
			align-items baseline
		h1
			margin 0
			color transparent
			-webkit-text-stroke 1px crimson
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
		&::-webkit-scrollbar
			width 4px
			background transparent
		&::-webkit-scrollbar-thumb
			background gray
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
		display flex
		align-items center
	#comments-sort
		grid-area comments-sort
		display flex
		align-items flex-end
		button
			margin 0
			border 1px dotted
			border-width 0 0 1px 1px
	#comments-actions
		grid-area comments-actions
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
	#inspector
		position fixed
		top 0
		width 100%
		height 100%
		overflow auto
		font 700 12px/1.2 monospace
		background #fed
</style>

<script>
	export state = {}
	export data = {}

	import img_reddit_logo from '/data/reddit_logo.svg'
	import Comments from '/comp/comments.svelte'
	import List from '/comp/list.svelte'
	import Inspector from '/comp/inspector.svelte'
	import Menu from '/comp/menu.svelte'
	import Post from '/comp/post.svelte'

	f_choose_object = (object) ->
		object.load_comments()
		state.object_id = object.id
		ls[object.id] = Date.now() / 1000
		data.OBJECT = new Promise (f, r) -> f object
	
	import { Key } from '/proc/input.coffee'
	document.addEventListener 'keydown',
		(e) -> switch e.code
			when Key[1]
				state.inspect = !state.inspect
</script>