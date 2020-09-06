<template>
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
	#rank-by
		padding: 16px
		padding-left: 64px
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
</script>