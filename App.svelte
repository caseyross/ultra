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
						h1 FRONT
				li
					a(href='/r/all')
						h1 ALL
				li
					a(href='/r/popular')
						h1 POPULAR
				li
					a(href='/')
						h1 SAVED
			button#show-keyboard-shortcuts
				| show keyboard shortcuts
				kbd ?
			ul
				li
					a(href='/')
						h2 MAIL
				li
					a(href='/r/all')
						h2 MODQUEUE
				li
					a(href='/')
						h2 PROFILE
				li
					a(href='/')
						h2 SETTINGS
		+await('data.LIST_DESCRIPTION')
			img#subreddit-icon
			+then('description')
				+if('description.community_icon')
					img#subreddit-icon(src='{description.community_icon}')
					+elseif('description.icon_img')
						img#subreddit-icon(src='{description.icon_img}')
					+else
						img#subreddit-icon(src='{img_reddit_logo}')
		#list-actions
			button
				| new
				kbd ^1
			button
				| rising
				kbd ^2
			button
				| hot
				kbd ^3
			button
				| contro.
				kbd ^4
			button
				| top
				kbd ^5
		List(LIST='{data.LIST}' choice='{state.object_id}' f_choose='{f_choose_object}' )
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
				| alpha
				kbd 1
			button
				| bravo
				kbd 2
			button
				| charlie
				kbd 3
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
		grid-template-columns 160px 464px 16px 1fr 16px 624px
		grid-template-rows 4rem 1fr
		grid-template-areas 'nav list-actions . object-actions . comments-actions' 'nav list . object . comments'
		overflow hidden
		background wheat
		color black
		font 300 14px monospace
		word-break break-word
	#nav
		grid-area nav
		li
			opacity 0.5
			&:hover
				opacity 1
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
	#comments-actions
		grid-area comments-actions
		padding-top 1rem
		border-bottom 1px solid gray
	#list-actions
		grid-area list-actions
		padding-top 1rem
		border-bottom 1px solid gray
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