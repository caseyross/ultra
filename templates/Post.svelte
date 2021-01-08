<script>

	export post = null
	export showOrigin = false

	import Avatar from '/templates/Avatar.svelte'
		
</script><template lang='pug'>

	.post
		Avatar(user='{post.author}')
		.text
			h2.title {post.title}
			span.time-since {Time.relative(post.times.submit, true)}
			a.origin(href='{post.nativeFeed.id}') {post.nativeFeed.id}
			span.flair(style!='border-color: {post.flairs.title.color}' title='{post.flairs.title.text}') &nbsp;{post.flairs.title.text}
		
</template><style>

	.post
		display flex
		padding 1ch
		word-break break-word
	.time-since
		flex 0 0 auto
		width 2.5rem
		margin-right 1rem
	.flair
		height 2.5rem
		font-size 1.5rem
		white-space nowrap
		overflow hidden
		text-overflow ellipsis
	.origin
		display none
		color gray

</style>