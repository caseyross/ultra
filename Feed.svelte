<template>
+await('$feed.DATA')
	+then('items')
		ol
			+each('items as post, i')
				li.envelope(
					tabindex=0
					on:click='{select_post(post)}'
					style!='background: {post_color(post)}; color: {contrast_color(post_color(post))}'
				)
					.stamp(
						style!='background: {post_color(post)}; color: {contrast_color(post_color(post))}'
					) {i < num_stickies(items) ? 'S' : i - num_stickies(items) + 1}
					.address
						h1.headline(
							class:md-spoiler-text!='{post.spoiler}'
							class:read!='{read_posts.has(post.id) && $selected.post.id !== post.id}'
							title='{Math.trunc(1000000 * post.score / post.subreddit_subscribers)} / {Math.trunc(1000000 * post.num_comments / post.subreddit_subscribers)}'
						) {post.title}
						span {post.subreddit.toLowerCase() === $feed.name.toLowerCase() ? post.flair : post.subreddit}
	+catch('error')
		.error-tag ERROR LOADING FEED
		.error-message {error}
</template>

<style>
	ol
		margin: 0
		padding: 0 12px
		height: 100%
		overflow: auto
		list-style: none
		display: flex
		flex-flow: column nowrap
		user-select: none
		cursor: pointer
		will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			display: none
	.envelope
		padding: 8px 0
		display: flex
	.meta
		color: gray
		display: flex
	.xpost-tag
	.sticky-tag
	.nsfw-tag
	.spoiler-tag
	.error-tag
		padding: 0 1px
		background: black
		color: white
		font-size: 10px
		font-weight: 700
	.error-tag
		background: red
	.headline
		margin: 0
		font-size: 16px
	.stamp
		flex: 0 0 28px
		height: 100%
		padding: 2px
		font-weight: bold
		display: flex
		justify-content: flex-end
		align-items: flex-start
	.address
		padding: 0 0 0 8px
	.read
		opacity: 0.2
	a
		color: inherit
		text-decoration: none
</style>

<script>
	import { feed, selected } from './state.coffee';
	import { contrast_color } from './color.coffee';
	export read_posts = new Set()
	num_stickies = (items) ->
		items.reduce(((sum, item) -> sum + item.is_sticky), 0)
	post_color = (post) ->
		post.link_flair_background_color or post.sr_detail.primary_color or post.sr_detail.key_color or '#000000'
	select_post = (post) ->
		post.fetch_comments()
		$selected.post = post
		read_posts.add post.id
		read_posts = read_posts
</script>