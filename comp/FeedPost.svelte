<template lang='pug'>

	table
		tr
			td.time-since
			td
				span.stats
					span.stat-icon(style!="color: {post.stats.score === 0 ? 'gray' : post.stats.score > 0 ? 'lightsalmon' : 'cornflowerblue'}") {post.flags.scoreHidden ? '🞄' : post.stats.score === 0 ? '🠶' : post.stats.score > 0 ? '🠉' : '🠋'}
					span.stat-value &nbsp;{post.flags.scoreHidden ? 'hidden' : post.stats.score}
					+if('post.awards.spend > 0')
						span.stat-icon(style!="color: goldenrod") ●
						span.stat-value(style!="margin-left: 0.5ch; margin-right: 0.25ch") {post.awards.spend}
				a.author(href='/u/{post.author.name}')
					span.author-name {post.author.name}
					+if('post.author.flair.text')
						span.author-flair {post.author.flair.text}
		tr
			td.flair
				span.feed-id {post.feed.id}
			td
				button(data-feed-selection='sdfsd')
					h2.headline
						span.submission-time {Time.relative(post.times.submit)}
						span.post-flair(style!="background: #333") {post.flair.text}
						| {post.content.title}
				

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
	.submission-time
		display none
		font-size 1rem
	.feed-id
		display none
		padding 0.5ch 1ch
		border-radius 1ch
		background #333
	.post-flair
		padding 0.5ch 1ch
		border-radius 1ch
		font-size 1.5rem
		margin-right 1ch

</style><script>

	export post = {}
		
</script>