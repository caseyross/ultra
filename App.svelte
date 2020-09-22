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
		#feed
			input(type='text' bind:value='{state.feed.name}')
			#rank-by
				button#hot(class:selected!='{state.feed.sort === "hot"}') Hot
				button#new(class:selected!='{state.feed.sort === "new"}') New
				button#rising(class:selected!='{state.feed.sort === "rising"}') Rising
				button#controversial(class:selected!='{state.feed.sort === "controversial"}') Controversial
				#rank-by-top
					button#top(class:selected!='{state.feed.sort === "top"}') Top:
					button#hour(class:selected!='{state.feed.sort === "top" && state.feed.filter === "hour"}') H
					button#day(class:selected!='{state.feed.sort === "top" && state.feed.filter === "day"}') D
					button#week(class:selected!='{state.feed.sort === "top" && state.feed.filter === "week"}') W
					button#month(class:selected!='{state.feed.sort === "top" && state.feed.filter === "month"}') M
					button#year(class:selected!='{state.feed.sort === "top" && state.feed.filter === "year"}') Y
					button#all(class:selected!='{state.feed.sort === "top" && state.feed.filter === "all"}') A
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
		+if('state.inspect')
			#inspector
				Inspector(value='{state}')
</template>

<style>
	main
		height 100%
		display grid
		grid-template-columns 30% 40% 30%
		grid-template-rows 1fr
		background #222
		color white
		font 300 12px/1.2 Verdana, sans-serif
		word-break break-word
	#top-nav
		display none
		flex 0 0 80px
		background #333
		img
			width 80px
			height 80px
			padding 8px
			object-fit contain
	#feed
		flex 0 0 320px
		padding 16px
		height 100%
		display flex
		flex-flow column nowrap
	#comments
		grid-area right
	#feed-nav
		height 64px
		display flex
		justify-content space-between
		align-items center
	#rank-by
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
	.selected
		text-decoration underline
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