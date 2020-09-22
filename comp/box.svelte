<template>
	li(
		tabindex=0
		class:read!='{is_read}'
		class:selected!='{is_selected}'
		on:mousedown!='{() => do_select()}'
	)
		h2(
			class:md-spoiler-text!='{item.spoiler}'
			title='{Math.trunc(1000000 * item.score / item.subreddit_subscribers)} / {Math.trunc(1000000 * item.num_comments / item.subreddit_subscribers)}'
		) {item.title}
		.meta
			span.domain {item.is_self ? '[text]' : item.is_gallery ? '[gallery]' : item.domain}
			span.age {item.age}
</template>

<style>
	li
		padding 4px 0
		cursor pointer
	.meta
		color gray
		display flex
		& > span
			margin-right 8px
	h2
		font-weight normal
	.read
		opacity 0.2
	.selected
		opacity 1
		color steelblue
	a
		color inherit
		text-decoration none
</style>

<script>
	import { contrast_color } from '/proc/color.coffee'
	export item = {}
	export is_selected = false
	export is_read = false
	export do_select = () -> {}
	tag = (item) -> switch
		when item.is_sticky then 'STICKY'
		when item.over_18 then 'NSFW'
		when item.spoiler then 'SPOIL'
		when item.locked then 'LOCK'
		when item.quarantine then 'QUAR'
</script>