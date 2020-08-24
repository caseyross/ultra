<template>
+await('$feed.DATA')
	+then('items')
		ol
			+each('items as post')
				li.brochure(tabindex=0)
					h1.headline(
						class:stickied!='{post.stickied || post.pinned}'
						class:md-spoiler-text!='{post.spoiler}'
						class:read!='{read_posts.has(post.id) && $selected.post.id !== post.id}'
						on:click='{select_post(post)}'
						title='{Math.trunc(1000000 * post.score / post.subreddit_subscribers)} / {Math.trunc(1000000 * post.num_comments / post.subreddit_subscribers)}'
					) 
						.flair-color(style='background: {post_color(post)}' title!='{post.subreddit.toLowerCase() === $feed.name.toLowerCase() ? post.flair : post.subreddit}')
						| {post.title}
					
	+catch('error')
		.error-tag ERROR LOADING FEED
		.error-message {error}
</template>

<style>
	ol
		margin: 0
		padding: 0
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
	.brochure
		padding: 8px 0
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
	.flair-color
		display: inline-block
		width: 16px
		height: 16px
		margin-right: 4px
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
	post_color = (post) ->
		post.link_flair_background_color or post.sr_detail.primary_color or post.sr_detail.key_color or '#000000'
	select_post = (post) ->
		post.fetch_comments()
		$selected.post = post
		read_posts.add post.id
		read_posts = read_posts
</script>