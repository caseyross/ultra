<template lang='pug'>

	h2.post
		.score {post.flags.scoreHidden ? '---' : post.stats.score}
		.headline
			+if('showOrigin')
				a.origin(href='/{post.listingId}') {post.listingId.slice(2)}
			.flair(style!='border-color: {post.flairs.title.color}' title='{post.flairs.title.text}') &nbsp;{post.flairs.title.text}
			.title {post.title}
		
</template><style>

	.post
		width 24rem
		margin 0
		word-break break-word
	.score
		display none
		text-align right
	.flair
		height 2.5rem
		font-size 1.5rem
		border 1px solid
		border-left 3rem solid
		white-space nowrap
		overflow hidden
		text-overflow ellipsis
	.origin
		display none
		color gray
	.title
		font-size 1.5rem
		background wheat
		color black
		padding 1ch

</style><script>

	export post = null
	export showOrigin = false
		
</script>