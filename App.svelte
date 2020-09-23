<template>
	svelte:head
		+await('state.feed.METADATA')
			title {state.feed.type + '/' + state.feed.name}
			+then('info')
				title {info.title}
	main
		nav#top-nav
			+await('state.feed.METADATA')
				img
				+then('info')
					+if('info.community_icon')
						img(src='{info.community_icon}')
						+elseif('info.icon_img')
							img(src='{info.icon_img}')
						+else
							img(src='{img_reddit_logo}')
		#input
			button(class:selected!='{state.feed.type === "r"}' on:click!='{() => state.feed.type = "r"}') subreddit
			span(style!='margin: 0 8px') ·
			button(class:selected!='{state.feed.type === "u"}' on:click!='{() => state.feed.type = "u"}') user
			input(type='text' bind:value='{state.feed.name}' placeholder='front page')
			#feed-sort
				button#new(class:selected!='{state.feed.sort === "new"}') new
				button#rising(class:selected!='{state.feed.sort === "rising"}') rising
				button#hot(class:selected!='{state.feed.sort === "hot"}') hot
				button#controversial(class:selected!='{state.feed.sort === "controversial"}') controversial
				#feed-sort-top
					button#top(class:selected!='{state.feed.sort === "top"}') top:
					button#hour(class:selected!='{state.feed.sort === "top" && state.feed.filter === "hour"}') h
					button#day(class:selected!='{state.feed.sort === "top" && state.feed.filter === "day"}') d
					button#week(class:selected!='{state.feed.sort === "top" && state.feed.filter === "week"}') w
					button#month(class:selected!='{state.feed.sort === "top" && state.feed.filter === "month"}') m
					button#year(class:selected!='{state.feed.sort === "top" && state.feed.filter === "year"}') y
					button#all(class:selected!='{state.feed.sort === "top" && state.feed.filter === "all"}') a
		#feed
			+await('state.feed.DATA')
				+then('items')
					BoxStack(
						items='{items}'
						selected_item='{state.item}'
						read_items='{state.feed.read}'
						do_select_item='{do_select_item}'
					)
				+catch('error')
					.error-tag ERROR LOADING FEED
					.error-message {error}
		+if('state.item.id')
			#post
				#post-meta
					h2 {state.item.title}
				#post-content
					+if('state.item.content.type === "html"')
						SelfText(text_html='{state.item.content.html}')
						+elseif('state.item.content.type === "image"')
							Gallery(images='{state.item.content.images}')
						+elseif('state.item.content.type === "video"')
							MediaPlayer(audio_url='{state.item.content.audio_url}' video_url='{state.item.content.url}' video_preview_url='{state.item.content.preview_url}')
						+elseif('state.item.content.type === "item"')
							+await('state.item.content.POST then content_post')
								Comments(post='{content_post}')
						+elseif('state.item.content.type === "link"')
							iframe(src='{state.item.content.url}' sandbox='allow-scripts allow-same-origin')
					Comments(post='{state.item}')
			+else
				#feed-description
					+await('state.feed.METADATA then info')
						img(src='{info.banner_background_image || info.banner_img}')
						article
							+html('info.description_html')
						+catch('error')
							article {error}
		Menu
		button#show-keyboard-shortcuts
			| show keyboard shortcuts
			|
			kbd ?
		+if('state.inspect')
			#inspector
				Inspector(value='{state}')
</template>

<style>
	main
		height 100%
		display grid
		grid-template-columns 22% 1fr
		grid-template-rows 144px minmax(0, 1fr)
		grid-template-areas 'feed-meta content' 'feed content'
		gap 0 48px
		background #222
		color white
		font 300 12px/1.5 Verdana, sans-serif
		word-break break-word
	#top-nav
		display none
		background #333
		img
			width 80px
			height 80px
			padding 8px
			object-fit contain
	#input
		grid-area feed-meta
		padding-left 48px
		padding-top 48px
	input[type=text]
		display block
		font-size 3vh
	#feed
		grid-area feed
		padding-left 32px
		overflow auto
		will-change transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			display none
	#post
		grid-area content
		padding-top 48px
		display flex
		flex-flow column nowrap
	#post-content
		flex 1
		padding-top 16px
		display flex
	#feed-nav
		height 64px
		display flex
		justify-content space-between
		align-items center
	#feed-sort
		display flex
		justify-content space-between
		align-items center
	#top
		width 32px
	#hour
	#day
	#month
	#week
	#year
	#all
		padding 4px
	button
		opacity 0.5
	.selected
		opacity 1
	#feed-description
		height 100%
		overflow auto
		display flex
		flex-flow column nowrap
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
	.xpost-tag
	.sticky-tag
	.nsfw-tag
	.spoiler-tag
	.error-tag
		padding 0 1px
		background black
		color white
		font-size 10px
		font-weight 700
	.error-tag
		background red
	#inspector
		position fixed
		top 0
		width 100%
		height 100%
		display flex
		overflow auto
		font 700 12px/1.2 monospace
		background #fed
</style>

<script>
	export state = null
	export load_feed = null

	import BoxStack from '/comp/box_stack.svelte'
	import Comments from '/comp/comments.svelte'
	import Gallery from '/comp/gallery.svelte'
	import Inspector from '/comp/inspector.svelte'
	import MediaPlayer from '/comp/media_player.svelte'
	import Menu from '/comp/menu.svelte'
	import SelfText from '/comp/self_text.svelte'
	import img_reddit_logo from '/data/reddit_logo.svg'
	import { Key } from '/proc/input.coffee'

	do_select_item = (item) ->
		item.fetch_comments()
		state.item = item
		state.feed.read.add item.id
		state.feed.read = state.feed.read
	
	window.addEventListener('popstate', () ->
		load_feed()
	)
	document.addEventListener('keydown', (e) ->
		switch e.code
			when Key[1]
				state.inspect = !state.inspect
	)
</script>