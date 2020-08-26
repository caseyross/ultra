<template>
.comment(
	tabindex=0
	on:click='{select_comment(comment)}'
	style='margin-left: {32 * (depth - 1)}px'
	class:selected='{comment.id === selected_id}'
	class:highlighted='{comment.id === highlight_id}'
	data-depth='{depth}'
	data-color='{comment_color(comment)}'
)
	+if('comment.is_more')
		.meta + {comment.count} more
		+else
			.meta
				a.author(on:click!='{() => feed.go("/u/" + comment.author)}' style!='background: {comment_color(comment)}; color: {contrast_color(comment_color(comment))}') {comment.author}
				+if('comment.author_flair_text')
					span.author-flair {comment.author_flair_text}
				+if('comment.total_awards_received > 0')
					span.awards(title='{awards_description(comment.all_awardings)}')
						+each('Object.entries(award_buckets(comment.all_awardings)) as bucket')
							+if('bucket[1].length')
								span(class='{bucket[0]}') {'$'.repeat(bucket[1].reduce((sum, award) => sum + award.count, 0))}
			.text {@html comment.body_html}
+each('comment.replies as comment')
	svelte:self(comment='{comment}' depth='{depth + 1}' op_id='{op_id}' highlight_id='{highlight_id}' selected_id='{selected_id}' select_comment='{select_comment}')
</template>


<style>
	.comment
		flex: 0 1 480px
		padding: 8px 4px 8px 8px
		&:focus
			background: #333
			color: white
	.meta
		color: gray
		display: flex
	.text
		margin-top: 6px
	.author
		cursor: pointer
	.author-flair
		margin-left: 6px
	.awards
		margin-left: 6px
	.argentium
		background: orangered
		color: black
		border: 1px solid
	.platinum
		background: white
		color: black
		border: 1px solid
	.gold
		color: goldenrod
	.silver
		color: #ccc
	.bronze
		color: rosybrown
	.selected
	.highlighted
		background: #333
		color: white
</style>

<script>
	import { feed } from './state.coffee'
	import { contrast_color } from './color.coffee'
	export comment =
		replies: []
	export depth = 1
	export op_id = ''
	export highlight_id = ''
	export selected_id = ''
	export select_comment = () -> {}
	distinguish_colors =
		op: 'lightskyblue'
		mod: 'darkseagreen'
		admin: 'orangered'
		special: 'crimson',
	comment_color = (comment) ->
		switch comment.distinguished
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
					'#666'
	award_buckets = (awards) ->
		buckets =
			argentium: []
			platinum: []
			gold: []
			silver: []
			bronze: []
		for award in awards.sort((a, b) -> (b.name < a.name) - 0.5)
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
					(award) -> "(#{award.count}) #{award.name}"
				).join('\n')
			else
				''
		).filter((x) -> x).join('\n\n')
</script>