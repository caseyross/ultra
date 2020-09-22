<template>
	section
		nav
		article
			#comments(bind:this='{dom.comments}' on:mousedown='{teleport_via_minimap}')
				+await('post.COMMENTS')
					#nocomments Loading...
					+then('comments')
						+if('post.num_comments > 0')
							+each('comments as comment')
								CommentTree(comment='{comment}' author_color='{post.feed_color}' op_id='{post.author_fullname}' highlight_id='{post.focal_comment_id}')
							+else
								#nocomments
									button#add-first-comment ADD THE FIRST COMMENT
			figure(bind:this='{dom.minimap}')
				canvas(bind:this='{dom.minimap_field}')
</template>

<style>
	minimap_width = 64px
	section
		height 100%
		flex 1 0 640px
		display flex
		flex-flow column nowrap
	nav
		flex 0 0 32px
		background #333
	article
		flex 1 0 auto
		contain strict
	#comments
		height 100%
		overflow-x auto
		overflow-y scroll
		will-change transform //https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		padding 16px
		&::-webkit-scrollbar
			width minimap_width
			background transparent
		&::-webkit-scrollbar-thumb
			border 1px dashed
	#nocomments
		height 100%
		display flex
		justify-content center
		align-items center
		text-align center
		font-weight 900
		color salmon
	#add-first-comment
		padding 40px
		border 1px dotted
		&:hover
		&:focus
			border-style solid
			text-decoration underline
	figure
		height 100%
		width minimap_width
		position absolute
		top 0
		right 0
		pointer-events none
</style>

<script>
	export post = {}

	import { onMount, afterUpdate } from 'svelte'
	import CommentTree from '/comp/comment_tree.svelte'
	
	dom =
		comments: {}
		minimap: {}
		minimap_field: {}
	teleport_via_minimap = (click) ->
		if dom.comments.clientWidth - click.layerX < 0
			dom.comments.scrollTop = click.layerY / dom.minimap.scrollHeight * dom.comments.scrollHeight - dom.minimap.scrollHeight / 2
	onMount () ->
		# <canvas> can't be sized properly in static CSS (only scaled)
		dom.minimap_field.width = dom.minimap.clientWidth
		dom.minimap_field.height = dom.minimap.clientHeight
	afterUpdate () ->
		await post.COMMENTS
		console.log('draw')
		draw_minimap()
	reset_scroll = () ->
		dom.comments.scrollTop = 0
	draw_minimap = () ->
		max_depth = 10
		canvas_context = dom.minimap_field.getContext '2d'
		canvas_context.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
		draw_comment_tree = (tree, current_depth) ->
			if (current_depth <= max_depth)
				[comment, ...reply_trees] = tree.children
				canvas_context.fillStyle = comment.dataset.color
				canvas_context.fillRect(
					dom.minimap.scrollWidth / max_depth * (current_depth - 1),
					Math.trunc(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight),
					8,
					comment.scrollHeight / dom.comments.scrollHeight * dom.minimap.scrollHeight
				)
				for tree in reply_trees
					draw_comment_tree(tree, current_depth + 1)
		for child in dom.comments.children
			if child.classList.contains 'comment-tree'
				draw_comment_tree(child, 1)
</script>