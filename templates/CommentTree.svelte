<template lang='pug'>
	
	.comment-tree
		+if('rootComment instanceof RedditComment')
			Comment(comment='{rootComment}')
			+each('rootComment.replies as reply')
				svelte:self(rootComment='{reply}')

</template><style>

	.comment-tree
		margin-left 2ch

</style><script>

	export rootComment = null

	import RedditComment from '/objects/RedditComment.coffee'
	import Comment from '/templates/Comment.svelte'

</script>