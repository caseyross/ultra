<template lang='pug'>
	.comment(
		tabindex=0
		class:selected='{comment.id === selected_id}'
		class:highlighted='{comment.id === highlight_id}'
	)
		+if('comment.is_more')
			.head
			.body ...
			+else
				.head
					img.author-distinguish-icon(src='{icon_gavel}')
					+if('comment.author_flair_body')
						span.author-flair {comment.author_flair_body}
					+if('comment.total_awards_received > 0')
						span.awards(title='{awards_description(comment.all_awardings)}')
							+each('Object.entries(award_buckets(comment.all_awardings)) as bucket')
								+if('bucket[1].length')
									span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
				.body
					p.meta {reltime(comment.created_utc)} by {comment.author}
					+html('formatted_comment_html(comment)')
					+each('comment.replies as comment')
						svelte:self(comment='{comment}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}')
</template>


<style>
	.comment
		margin-top 1.5rem
		display flex
	p
		max-width 480px
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
</style>

<script>
	export comment =
		replies: []
	export op_id = ''
	export highlight_id = ''
	export selected_id = ''

	import { contrast_color } from '/proc/color.coffee'
	import { rating, rating_color } from '/proc/rating.coffee'
	import { reltime } from '/proc/time.coffee'
	import icon_gavel from '/data/gavel.svg'

	formatted_comment_html = (comment) ->
		comment.body_html[16...-6]
	distinguish_colors =
		op: 'lightskyblue'
		mod: 'mediumspringgreen'
		admin: 'orangered'
		special: 'crimson',
	comment_color = (comment) -> switch comment.distinguished
		when 'moderator'
			distinguish_colors.mod
		when 'admin'
			distinguish_colors.admin
		when 'special'
			distinguish_colors.special
		else
			if comment.author_fullname == op_id
				distinguish_colors.op
			else
				'gray'
	award_buckets = (awards) ->
		buckets =
			argentium: []
			platinum: []
			gold: []
			silver: []
			bronze: []
		for award in awards.sort((a, b) -> (if a.count is b.count then b.name < a.name else a.count < b.count) - 0.5)
			switch
				when award.coin_price < 100
					buckets.bronze.push award
				when award.coin_price < 500
					buckets.silver.push award
				when award.coin_price < 1800
					buckets.gold.push award
				when award.coin_price < 20000
					buckets.platinum.push award
				else
					buckets.argentium.push award
		buckets
	awards_description = (awards) ->
		Object.entries(award_buckets(awards)).map((bucket) ->
			if bucket[1].length
				"#{bucket[0].toUpperCase()} AWARDS\n" +
				bucket[1].map(
					(award) ->
						"#{award.count}x #{award.name}"
				).join('\n')
			else
				''
		).filter((x) -> x).join('\n\n')
</script>