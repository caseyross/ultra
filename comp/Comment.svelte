<template lang='pug'>
	
	.comment(tabindex=0)
		+if('comment instanceof MoreComments')
			.head
			.body ...
			+else
				.head
					img.author-distinguish-icon
					+if('comment.author_flair_body')
						span.author-flair {comment.author_flair_body}
					+if('comment.total_awards_received > 0')
						span.awards
				.body
					p.meta {Time.relative(comment.created_utc)} by {comment.author}
					+html('comment.body')

</template><style>

	.comment
		margin-top 1.5rem
		display flex
	p
		max-width 60rem
	.head
		flex 0 0 1rem
		margin-right 1rem
		color gray
	.meta
		color rgba(0,0,0,0.2)
	.author
		display block
		padding 2px
		border 1px solid
	.author-distinguish-icon
		display inline-block
		display none
		width 16px
		height 16px
	.author-flair
	.awards
		margin-left 6px
		display none
	.argentium
		background orangered
		color black
		border 1px solid
	.platinum
		background white
		color black
		border 1px solid
	.gold
		color goldenrod
	.silver
		color #ccc
	.bronze
		color rosybrown

</style><script>

	export comment =
		replies: []

	distinguishColors =
		op: 'lightskyblue'
		mod: 'mediumspringgreen'
		admin: 'orangered'
		special: 'crimson',
	commentColor = (comment) -> switch comment.distinguish
		when 'moderator'
			distinguishColors.mod
		when 'admin'
			distinguishColors.admin
		when 'special'
			distinguishColors.special
		else
			if comment.author_fullname == opId
				distinguishColors.op
			else
				'gray'

</script>