<template lang='pug'>
	li(
		tabindex=0
		class:read
		class:selected
		on:mousedown='{select}'
	)
		.meta
			span {object.subreddit}
			span {object.flair}
		h1(
			class:md-spoiler-text!='{object.spoiler}'
			title='{Math.trunc(1000000 * object.score / object.subreddit_subscribers)} / {Math.trunc(1000000 * object.num_comments / object.subreddit_subscribers)}'
		) {object.title}
		.meta
			span.domain {object.is_self ? '[text]' : object.is_gallery ? '[gallery]' : object.domain}
			span.age {object.age}
</template>

<style>
	li
		padding 16px
		cursor pointer
		border-radius: 16px
		&:hover
		&.selected
			opacity 1
			background: #333
	.meta
		color gray
		display flex
		& > span
			margin-right 8px
	h1
		font-weight normal
		font-size: 15px
	.read
		opacity 0.2
	a
		color inherit
		text-decoration none
</style>

<script>
	export object = {}
	export select = () -> {}
	export selected = false
	export read = false
	
	import { contrast_color } from '/proc/color.coffee'
	
	tag = (object) -> switch
		when object.is_sticky then 'STICKY'
		when object.over_18 then 'NSFW'
		when object.spoiler then 'SPOIL'
		when object.locked then 'LOCK'
		when object.quarantine then 'QUAR'
</script>