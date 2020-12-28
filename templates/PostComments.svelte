<template lang='pug'>

	#comments
		+each('comments.list as topLevelComment')
			#top-level-comment
				Comment(comment='{topLevelComment}')
			+else
				#nocomments
					button#add-first-comment ADD THE FIRST COMMENT

</template><style>

	#comments
		flex 0 0 auto
		display flex
		flex-flow column wrap
		place-content flex-start
		overflow auto
	#top-level-comment
		width 320px
		max-height 100%
	#nocomments
		height 100%
		display flex
		justify-content center
		align-items center
		text-align center
		font-weight 900
		color salmon
	#add-first-comment
		padding 40px
		border 1px dotted
		&:hover
		&:focus
			border-style solid
			text-decoration underline

</style><script>

	export comments = {}

	import Comment from '/templates/Comment.svelte'

</script>