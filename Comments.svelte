<template>
	section
		#comments(bind:this='{dom.comments}' on:mousedown='{teleport_via_minimap}')
			+await('post.COMMENTS')
				#nocomments Loading...
				+then('comments')
					+if('post.num_comments > 0')
						article(use:reset_scroll use:draw_minimap)
							+each('comments as comment')
								CommentTree(comment='{comment}' op_id='{post.author_fullname}' highlight_id='{post.focal_comment_id}' selected_id='{$selected.comment?.id}' select_comment='{select_comment}')
						+else
							#nocomments
								button#add-first-comment ADD THE FIRST COMMENT
		figure(bind:this='{dom.minimap}')
			canvas(bind:this='{dom.minimap_field}')
</template>

<style>
	section
		height: 100%
		contain: strict
	#comments
		height: 100%
		overflow: auto
		will-change: transform //https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			width: 64px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: rgba(0,0,0,0.2)
	#nocomments
		height: 100%
		display: flex
		justify-content: center
		align-items: center
		text-align: center
		font-weight: 900
		color: salmon
	#add-first-comment
		padding: 40px
		border: 1px dotted
		&:hover
		&:focus
			border-style: solid
			text-decoration: underline
	figure
		height: 100%
		width: 64px
		position: absolute
		top: 0
		right: 0
		pointer-events: none
</style>

<script>
	import { onMount } from 'svelte'
	import { feed, selected } from './state.coffee';
	import CommentTree from './CommentTree.svelte'
	export post = {}
	select_comment = (comment) ->
		$selected.comment = comment
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
	reset_scroll = () ->
		dom.comments.scrollTop = 0
	draw_minimap = () ->
		canvas_context = dom.minimap_field.getContext '2d'
		max_depth = 10
		draw_symbols_for_children = (parent, children_depth) ->
			if (children_depth <= max_depth)
				for element in parent.children
					if element.classList.contains("comment") and element.children.length > 1
						canvas_context.fillStyle = element.dataset.color
						canvas_context.fillRect(
							dom.minimap.scrollWidth / max_depth * (children_depth - 1),
							Math.trunc(element.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight),
							element.children[1].scrollHeight / dom.minimap.scrollWidth * dom.minimap.scrollWidth,
							(element.children[0].scrollHeight + element.children[1].scrollHeight) / dom.comments.scrollHeight * dom.minimap.scrollHeight
						)
						draw_symbols_for_children(element, children_depth + 1)
		canvas_context.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
		draw_symbols_for_children(dom.comments.firstChild, 1)
</script>