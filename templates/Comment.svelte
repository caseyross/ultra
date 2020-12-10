<template lang='pug'>
	
	.comment
		+if('comment instanceof RedditComment')
			.stats
				Score(score='{comment.stats.score}' scoreHidden='{comment.flags.scoreHidden}')
			.text
				+html('comment.content.text')
			+elseif('comment instanceof RedditMoreComments')
			+else
				.error-tag ERROR LOADING COMMENT

</template><style>

	.comment
		display grid
		grid-template-columns 9rem 37rem
		gap 1rem
		padding-top 2ch
		font-weight 300
		line-height 1.5
	.stats
		align-self flex-start
		justify-self flex-end

</style><script>

	export comment = null

	import RedditComment from '/objects/RedditComment'
	import RedditMoreComments from '/objects/RedditMoreComments'
	import Score from '/templates/Score.svelte'

</script>