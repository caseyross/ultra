<template lang='pug'>

	.post
		.stats
			Score(score='{post.stats.score}' scoreHidden='{post.flags.scoreHidden}')
		h2.title
			+if('post.flair.text')
				span.flair(style!='color: {post.flair.color}') {post.flair.text}
			| {post.content.title}
		
</template><style>

	.post
		display grid
		grid-template-columns 9rem 57rem
		font-size 2rem
		padding 1ch
	.flair
		margin-right 1ch
	.title
		margin 0
		font-size 2rem

</style><script>

	export post = null

	import Score from '/templates/Score.svelte'
		
</script>