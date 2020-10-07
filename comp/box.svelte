<template lang='pug'>
	li(
		tabindex=0
		class:is_read
		class:is_chosen
		on:mousedown='{f_choose}'
	)
		figure {content_type_icon(object)}
		.txt
			span(style='color: gray; margin-right: 1rem') {object.flair}
			h3(
				class:md-spoiler-text!='{object.spoiler}'
				title='{Math.trunc(1000000 * object.score / object.subreddit_subscribers)} / {Math.trunc(1000000 * object.num_comments / object.subreddit_subscribers)}'
			) {object.title}
</template>

<style>
	li
		cursor pointer
		display flex
		opacity 0.8
		text-transform uppercase
		border 1px solid transparent
		&:hover
			opacity 1
		&.is_chosen
			opacity 1
			border-color inherit
	figure
		flex: 0 0 3rem
		margin 0.5rem 0 0 0
		font-size 4rem
		display flex
		justify-content center
	.is_read
		opacity 0.2
</style>

<script>
	export object = {}
	export is_read = false
	export is_chosen = false
	export f_choose = () -> {}
	
	import { contrast_color } from '/proc/color.coffee'
	
	content_type_icon = (object) -> switch object.content.type
		when 'html' then '≣'
		when 'image'
			if object.is_gallery then '⊟' else '⊡'
		else '⇰'
		# ⍟ ⛏ ♬ ☣ ☢ ☠ ☄ ⚠ ⛞ ⛨
	tag = (object) -> switch
		when object.is_sticky then 'STICKY'
		when object.over_18 then 'NSFW'
		when object.spoiler then 'SPOIL'
		when object.locked then 'LOCK'
		when object.quarantine then 'QUAR'
</script>