<template lang='pug'>
	
	.comment
		+if('comment instanceof RedditComment')
			+html('comment.content.text')
			+elseif('comment instanceof RedditMoreComments')
			+else
				.error-tag ERROR LOADING COMMENT

</template><style>

	.comment
		margin 0.5ch 0
		padding 0.5ch 1ch

</style><script>

	export comment = null

	import RedditComment from '/objects/RedditComment'
	import RedditMoreComments from '/objects/RedditMoreComments'

</script>