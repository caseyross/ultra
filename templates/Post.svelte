<template lang='pug'>

	h2.post
		.score {post.flags.scoreHidden ? '---' : post.stats.score}
		.headline
			+if('showOrigin')
				a.origin(href='/{post.feed.id}') {post.feed.id.slice(2)}
				+elseif('post.flair.text')
					span.flair(style!='border-color: {post.flair.color}') {post.flair.text}
					span.spacer
			span.title {post.content.title}
		
</template><style>

	.post
		display grid
		grid-template-columns 9rem 57rem
		font-size 2rem
		margin 0
		padding 1ch
	.score
		text-align right
	.flair
		font-size 1.5rem
		border 1px solid
		border-left 1rem solid
		display block
	.origin
		display none
		color gray
	.spacer
		display inline-block
		width 1ch

</style><script>

	export post = null
	export showOrigin = false

	import Score from '/templates/Score.svelte'
		
</script>