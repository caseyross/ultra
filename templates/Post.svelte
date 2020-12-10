<template lang='pug'>

	.post
		.stats
			Score(score='{post.stats.score}' scoreHidden='{post.flags.scoreHidden}')
		h2.title {post.content.title}
		
</template><style>

	.post
		display grid
		grid-template-columns 9rem 57rem
		gap 1rem
	.stats
		align-self flex-start
		justify-self flex-end
	.title
		margin 0
		font-size 2.25rem
		font-weight 200

</style><script>

	export post = null

	import Score from '/templates/Score.svelte'
		
</script>