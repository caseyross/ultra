<template>
	#app
		#feed
			FeedCommand
			FeedRanking
			Feed
		+if('$selected.post')
			+if('$selected.post.content.type !== "empty"')
				#post
					Post(post='{$selected.post}')
			#comments
				Comments(post='{$selected.post}')
			+else
				#sidebar
					+await('$feed.METADATA then info')
						img(src='{info.banner_background_image || info.banner_img}')
						article {@html info.description_html}
						+catch('error')
							article {error}
		Menu
	svelte:head
		+await('$feed.METADATA')
			title {$feed.type + '/' + $feed.name}
			+then('info')
				title {info.title}
	+if('$selected.inspect_mode')
		#inspector
			+if('$selected.inspect_mode === "state"')
				Inspector(value='{$feed}')
				+elseif('$selected.inspect_mode === "post"')
					Inspector(value='{$selected.post}')
				+elseif('$selected.inspect_mode === "comment"')
					Inspector(value='{$selected.comment}')
				+elseif('$selected.inspect_mode === "feed"')
					+await('$feed.METADATA then info') 
						Inspector(value='{info}')
</template>

<style>
	#app
		height: 100%
		background: #222
		color: white
		font: 400 12px/1.2 "Iosevka Aile", sans-serif
		word-break: break-word
		display: flex
	img
		width: 100%
		max-height: 288px
		object-fit: cover
		margin-bottom: 16px
	#feed
		flex: 0 0 480px
		height: 100%
		display: flex
		flex-flow: column nowrap
	#sidebar
		height: 100%
		overflow: auto
		display: flex
		flex-flow: column nowrap
		&::-webkit-scrollbar
			width: 4px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: gray
	#post
		flex: 0 0 800px
		height: 100%
		padding-left: 16px
		display: flex
		flex-flow: column nowrap
		justify-content: center
		align-items: center
	#comments
		flex: 1 0 640px
		padding-left: 16px
	#inspector
		position: fixed
		top: 0
		width: 100%
		height: 100%
		display: flex
		overflow: auto
		font: 700 12px/1.2 monospace
		background: #fed
</style>

<script>
	import { feed, selected } from './state.coffee'
	import { Key } from './input.coffee'
	import FeedCommand from './FeedCommand.svelte'
	import FeedRanking from './FeedRanking.svelte'
	import Feed from './Feed.svelte'
	import Post from './Post.svelte'
	import Comments from './Comments.svelte'
	import Menu from './Menu.svelte'
	import Inspector from './Inspector.svelte'
	window.addEventListener('popstate', () ->
		feed.go()
	)
	document.addEventListener('keydown', (e) ->
		switch e.code
			when Key[1]
				if $selected.inspect_mode is 'post'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'post'
			when Key[2]
				if $selected.inspect_mode is 'feed'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'feed'
			when Key[3]
				if $selected.inspect_mode is 'comment'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'comment'
			when Key[4]
				if $selected.inspect_mode is 'state'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'state'
	)
</script>