<template>
	#feed-command
		+await('$feed.METADATA')
			img
			+then('info')
				+if('info.community_icon')
					img(src='{info.community_icon}')
					+elseif('info.icon_img')
						img(src='{info.icon_img}')
					+else
						img(src='{img_reddit_logo}')
		input(type='text' value='{$feed.type}/{$feed.name}' on:change!='{(e) => feed.go("/" + e.target.value)}')
</template>

<style>
	#feed-command
		display: flex
		justify-content: space-between
		align-items: center
	input[type=text]
		width: 100%
		font-size: 32px
		font-weight: 700
		&:focus
		&:hover
			color: salmon
	img
		height: 64px
		flex: 0 0 64px
		margin-right: 16px
</style>

<script>
	import { feed } from './state.coffee'
	import img_reddit_logo from './reddit_logo.svg'
</script>