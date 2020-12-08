<template lang='pug'>

	a(href='{post.permalink}')
		table
			tr
				td.time-since
				td
					span.stats
						span.stat-icon(style!="color: {post.stats.score === 0 ? 'gray' : post.stats.score > 0 ? 'lightsalmon' : 'cornflowerblue'}") {post.flags.scoreHidden ? '🞄' : post.stats.score === 0 ? '🠶' : post.stats.score > 0 ? '🠉' : '🠋'}
						span.stat-value &nbsp;{post.flags.scoreHidden ? 'new' : post.stats.score}
						+if('post.awards.spend > 0')
							span.stat-icon(style!="color: goldenrod") ●
							span.stat-value(style!="margin-left: 0.5ch; margin-right: 0.25ch") {post.awards.spend}
					a.author(href='/u/{post.author.name}')
						span.author-name {post.author.name}
						+if('post.author.flair.text')
							span.author-flair {post.author.flair.text}
					span.stats(style!="float: right; display: none")
						span.stat-icon(style!="color: greenyellow; opacity: {Color.recency(post.times.submit)}") ◔
						span.stat-value &nbsp;{Time.relative(post.times.submit)}
			tr
				td.flair
					span.post-flair(style!="color: {post.flair.color}") {post.flair.text}
					span.feed-id {post.feed.id}
				td
					h2.headline {post.content.title}
				

</template><style>

	table
		font inherit
		button
			display block
			text-align left
	.stats
		padding 0.5ch 1ch
		background #333
		border-radius 1ch
	.stat-value
		font-size 0.8rem
		& ~ .stat-icon
			margin-left 1ch
	.author
		padding 0.5ch 1ch
		border-radius 1ch
	.author-flair
		margin-left 1ch
		color gray
		font-style italic
	.flair
		width 16ch
		text-align right
		vertical-align top
	.headline
		margin 0
		width 32ch
		font-size 2rem
		font-weight 200
		line-height 1.25
	.feed-id
		display none
		padding 0.5ch 1ch
		border-radius 1ch
		background #333
	.post-flair
		display none
		padding 0.5ch 1ch
		border-radius 1ch
		border 1px solid

</style><script>

	export post = {}
		
</script>