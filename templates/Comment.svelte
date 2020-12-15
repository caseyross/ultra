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
		font-weight 300
	.stats
		align-self flex-start
		justify-self flex-end

</style><script>

	export comment = null

	import RedditComment from '/objects/RedditComment'
	import RedditMoreComments from '/objects/RedditMoreComments'
	import Score from '/templates/Score.svelte'

	###
	badgeText = (type) -> switch type
		when 'op' then 'OP'
		when 'mod' then 'Mod'
		when 'admin' then 'Admin'
		when 'special' then '???'
	badgeHtml = ''
	for type in comment.badges
		badgeHtml += "<span class='badge badge-#{type}'>(#{badgeText(type)})</span>"

	textHtml = comment.content.text[..2] + badgeHtml + comment.content.text[3..]
	###

</script>