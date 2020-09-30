<template lang='pug'>
	svelte:head
		+await('data.LIST_DESCRIPTION')
			title {state.list_id}
			+then('description')
				title {description.title}
	main
		nav#top-nav
			+await('data.LIST_DESCRIPTION')
				img
				+then('description')
					+if('description.community_icon')
						img(src='{description.community_icon}')
						+elseif('description.icon_img')
							img(src='{description.icon_img}')
						+else
							img(src='{img_reddit_logo}')
		#input
			button(class:selected!='{state.list_id[0] !== "u"}' on:click!='{() => state.list_id = "r/"}') subreddit
			span(style!='margin: 0 8px') ·
			button(class:selected!='{state.list_id[0] === "u"}' on:click!='{() => state.list_id = "u/"}') user
			input(type='text' value!='{state.list_id.split("/")[1]}' placeholder='front page')
			#list-sort
				button#new(class:selected!='{state.list_rank_by === "new"}') new
				button#rising(class:selected!='{state.list_rank_by === "rising"}') rising
				button#hot(class:selected!='{state.list_rank_by === "hot"}') hot
				button#controversial(class:selected!='{state.list_rank_by === "controversial"}') controversial
				#list-sort-top
					button#top(class:selected!='{state.list_rank_by === "top"}') top:
					button#hour(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "hour"}') h
					button#day(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "day"}') d
					button#week(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "week"}') w
					button#month(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "month"}') m
					button#year(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "year"}') y
					button#all(class:selected!='{state.list_rank_by === "top" && state.list.time_period === "all"}') a
		ol#list
			+await('data.LIST')
				+then('list')
					+each('list as object')
						Box(
							object='{object}'
							select!='{() => select_object(object)}'
							selected!='{state.object_id === object.id}'
							read='{ls[object.id]}'
						)
				+catch('error')
					.error-tag ERROR LOADING FEED
					.error-message {error}
		+await('data.OBJECT')
			#list-description
				+await('data.LIST_DESCRIPTION then description')
					img(src='{description.banner_background_image || description.banner_img}')
					article
						+html('description.description_html')
					+catch('error')
						article {error}
			+then('object')
				#post
					#post-meta
						h2 {object.title}
					#post-content
						+if('object.content.type === "html"')
							SelfText(text_html='{object.content.html}')
							+elseif('object.content.type === "image"')
								Gallery(images='{object.content.images}')
							+elseif('object.content.type === "video"')
								MediaPlayer(audio_url='{object.content.audio_url}' video_url='{object.content.url}' video_preview_url='{object.content.preview_url}')
							+elseif('object.content.type === "item"')
								+await('object.content.LINKED_OBJECt then linked_object')
									Comments(post='{linked_object}')
							+elseif('object.content.type === "link"')
								iframe(src='{object.content.url}' sandbox='allow-scripts allow-same-origin')
						Comments(post='{object}')
			+catch('error')
				.error-tag ERROR LOADING POST
				.error-message {error}
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
		grid-template-areas 'list-meta content' 'list content'
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
		grid-area list-meta
		padding-left 48px
		padding-top 48px
	input[type=text]
		display block
		font-size 3vh
	#list
		grid-area list
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
	#list-nav
		height 64px
		display flex
		justify-content space-between
		align-items center
	#list-sort
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
	ol
		user-select: none
	#list-description
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
	export state = {}
	export data = {}

	import img_reddit_logo from '/data/reddit_logo.svg'
	import Box from '/comp/box.svelte'
	import Comments from '/comp/comments.svelte'
	import Gallery from '/comp/gallery.svelte'
	import Inspector from '/comp/inspector.svelte'
	import MediaPlayer from '/comp/media_player.svelte'
	import Menu from '/comp/menu.svelte'
	import SelfText from '/comp/self_text.svelte'

	select_object = (object) ->
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