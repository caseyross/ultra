<template>
	+await('$feed.DATA')
		+then('items')
			ol
				+each('items as post, i')
					li.envelope(
						tabindex=0
						on:click='{select_post(post)}'
					)
						.left(style!='color: {post.flair_color}') {post.subreddit.toLowerCase() === $feed.name.toLowerCase() ? (tag(post) || i - num_stickies(items) + 1) : (tag(post) || i + 1)}
						.right
							h2.headline(
								class:md-spoiler-text!='{post.spoiler}'
								class:read!='{read_posts.has(post.id) && $selected.post.id !== post.id}'
								title='{Math.trunc(1000000 * post.score / post.subreddit_subscribers)} / {Math.trunc(1000000 * post.num_comments / post.subreddit_subscribers)}'
							) {post.title}
							.meta
								span.domain {post.is_self ? '[text]' : post.domain}
								+if('$feed.name.toLowerCase() !== post.subreddit.toLowerCase()')
									span.subreddit {post.subreddit}
								span.flair(style!='background: {post.flair_color}; color: {contrast_color(post.flair_color)}') {post.flair}
								span.age {post.age}
								span.author {post.author}
		+catch('error')
			.error-tag ERROR LOADING FEED
			.error-message {error}
</template>

<style>
	ol
		height: calc(100% - 110px)
		overflow: auto
		margin: 0
		padding: 0
		user-select: none
		will-change: transform // https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			display: none
	.envelope
		padding: 4px 0
		cursor: pointer
		display: flex
	.left
		flex: 0 0 48px
		height: 19px
		display: flex
		justify-content: flex-end
		align-items: flex-end
		font-weight: bold
		color: gray
	.right
		padding: 0 16px
	.meta
		color: gray
		display: flex
		& > span
			margin-right: 8px
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
	tag = (post) -> switch
		when post.is_sticky then 'STICKY'
		when post.over_18 then 'NSFW'
		when post.spoiler then 'SPOIL'
		when post.locked then 'LOCK'
		when post.quarantine then 'QUAR'
	# TODO: tag explanation mouseover text
	num_stickies = (items) ->
		items.reduce(((sum, item) -> sum + item.is_sticky), 0)
	select_post = (post) ->
		post.fetch_comments()
		$selected.post = post
		read_posts.add post.id
		read_posts = read_posts
</script>