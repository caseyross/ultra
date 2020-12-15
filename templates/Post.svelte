<template lang='pug'>

	h2.post
		.stats
			Score(score='{post.stats.score}' scoreHidden='{post.flags.scoreHidden}')
		.headline
			+if('showOrigin')
				span.origin {post.feed.id.slice(2)}
				span.spacer
				+elseif('post.flair.text')
					span.flair(style!='color: {post.flair.color}') {post.flair.text}
					span.spacer
			span.title {post.content.title}
		
</template><style>

	.post
		display grid
		grid-template-columns 9rem 57rem
		font-size 2rem
		margin 0
		padding 1ch
	.origin
		color gray
	.spacer
		display inline-block
		width 1ch

</style><script>

	export post = null
	export showOrigin = false

	import Score from '/templates/Score.svelte'
		
</script>