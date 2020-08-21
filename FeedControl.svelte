<template>
nav
	#feed-select
		input(type='text' value='{$feed.type}/{$feed.name}' on:change!='{(e) => feed.go("/" + e.target.value)}')
		+await('$feed.METADATA')
			img(src='{img_reddit_logo}')
			+then('info')
				+if('info.community_icon')
					img(src='{info.community_icon}')
					+elseif('info.icon_img')
						img(src='{info.icon_img}')
					+else
						img(src='{img_reddit_logo}')
	#rank-by
		button#hot(class:selected!='{$feed.rank_by.type === "hot"}') Hot
		button#new(class:selected!='{$feed.rank_by.type === "new"}') New
		button#rising(class:selected!='{$feed.rank_by.type === "rising"}') Rising
		button#controversial(class:selected!='{$feed.rank_by.type === "controversial"}') Controversial
		#rank-by-top
			button#top(class:selected!='{$feed.rank_by.type === "top"}') Top:
			button#hour(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "hour"}') H
			button#day(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "day"}') D
			button#week(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "week"}') W
			button#month(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "month"}') M
			button#year(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "year"}') Y
			button#all(class:selected!='{$feed.rank_by.type === "top" && $feed.rank_by.filter === "all"}') A
</template>

<style>
	nav
		margin-bottom: 16px
	#feed-select
		padding-top: 20px
		margin-bottom: 8px
		display: flex
		justify-content: space-between
	input[type=text]
		width: 100%
		font-size: 24px
		height: 36px
		&:focus
		&:hover
			color: salmon
	img
		height: 48px
		flex: 0 0 auto
		margin-left: 8px
	#rank-by
		margin: 0
		padding: 0
		display: flex
		justify-content: space-between
		align-items: center
	#top
		width: 32px
	#hour
	#day
	#month
	#week
	#year
	#all
		width: 16px
	.selected
		text-decoration: underline
</style>

<script>
	import { feed } from './state.coffee'
	import img_reddit_logo from './reddit_logo.svg'
</script>