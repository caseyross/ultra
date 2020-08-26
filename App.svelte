<template>
#app
	+await('$feed.METADATA')
		img
		+then('info')
			img(src='{info.banner_background_image}')
	#left
		+if('$selected.post.id')
			Post(post='{$selected.post}')
			+else
				Sidebar
	#center
		FeedControl
		Feed
	#right
		+if('$selected.post.id')
			Comments(post='{$selected.post}')
	MouseMenu
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
		font: 400 12px/1.2 monospace
		word-break: break-word
	img
		width: 100%
	#center
		position: absolute
		top: 16px
		left: 16px
		width: 384px
		height: calc(100% - 16px)
		padding: 0 16px
		background: #333
		display: flex
		flex-flow: column nowrap
	#left
	#right
		position: absolute
		top: 16px
		width: calc((100% - 400px) / 2 - 16px)
		height: calc(100% - 32px)
	#left
		left: 416px
	#right
		right: 0
		padding: 8px 0 0 8px
		background: #333
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
	import keymap from './keymap.coffee'
	import FeedControl from './FeedControl.svelte'
	import Sidebar from './Sidebar.svelte'
	import Feed from './Feed.svelte'
	import Post from './Post.svelte'
	import Comments from './Comments.svelte'
	import MouseMenu from './MouseMenu.svelte'
	import Inspector from './Inspector.svelte'
	window.addEventListener('popstate', () ->
		feed.go()
	)
	document.addEventListener('keydown', (e) ->
		switch e.key
			when keymap.inspect.post
				if $selected.inspect_mode is 'post'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'post'
			when keymap.inspect.feed
				if $selected.inspect_mode is 'feed'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'feed'
			when keymap.inspect.comment
				if $selected.inspect_mode is 'comment'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'comment'
			when keymap.inspect.state
				if $selected.inspect_mode is 'state'
					$selected.inspect_mode = ''
				else
					$selected.inspect_mode = 'state'
	)
</script>