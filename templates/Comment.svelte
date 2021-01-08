<script>

	export depth = 0
	export comment = null

	import RedditComment from '/objects/RedditComment'
	import RedditMoreComments from '/objects/RedditMoreComments'
	import Avatar from '/templates/Avatar.svelte'

	if comment instanceof RedditComment
		commentClass = (if comment.distinguish then 'comment-' + comment.distinguish else '') + ' ' + (if comment.flags.removed then 'removed' else '')
		commentStyle = "margin-left: #{depth * 2}ch; opacity: #{0.5 + comment.stats.rating / 10}"
		commentHoverText = comment.stats.ratingExplanation
	else if comment instanceof RedditMoreComments
		commentStyle = "color: gray"

</script><template lang='pug'>
	
	+if('comment instanceof RedditComment')
		.comment(class='{commentClass}' style='{commentStyle}' title='{comment.stats.score} points {Time.relative(comment.times.submit)} by u/{comment.author.name} ({commentHoverText})')
			Avatar(user='{comment.author}')
			.text
				+html('comment.content.text')
		+elseif('comment instanceof RedditMoreComments')
			a(href='/') {comment.ids.length} MORE
		+else
			.error-tag ERROR LOADING COMMENT
	+each('comment.replies as reply')
		svelte:self(comment='{reply}' depth='{depth + 1}')

</template><style>

	.comment
		position relative
		padding 1ch
		display flex
	.removed
		opacity 0.2
		text-decoration line-through

</style>