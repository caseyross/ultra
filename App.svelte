<template>
#app
	+await('$feed.METADATA')
		img
		+then('info')
			img(src='{info.banner_background_image}')
			Sidebar
	#content
		#feed
			FeedControl
			Feed
		+if('$selected.post')
			+if('$selected.post.content')
				#post
					Post(post='{$selected.post}')
		+if('$selected.post')
			#comments
				Comments(post='{$selected.post}')
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
		font: 400 12px/1.2 monospace
		word-break: break-word
	img
		width: 100%
		max-height: 384px
		object-fit: cover
	#content
		position: absolute
		top: 0
		left: 0
		width: 100%
		height: 100%
		display: flex
	#feed
		flex: 0 0 384px
		margin: 16px 0 0 16px
		background: #333
	#post
		flex: 0 1 calc((100% - 384px) / 2)
		margin: 16px 0 0 16px
	#comments
		flex: 1 0 calc((100% - 384px) / 2)
		margin: 16px 0 0 16px
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
	import FeedControl from './FeedControl.svelte'
	import Sidebar from './Sidebar.svelte'
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