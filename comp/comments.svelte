<template>

	article
		#comments(bind:this='{dom.comments}' on:mousedown='{teleport_via_minimap}')
			+await('post.COMMENTS')
				#nocomments Loading...
				+then('comments')
					+if('post.num_comments > 0')
						+each('comments as comment')
							Comment(comment='{comment}' op_id='{post.author_fullname}' highlight_id='{post.focal_comment_id}')
						+else
							#nocomments
								button#add-first-comment ADD THE FIRST COMMENT
		figure(bind:this='{dom.minimap}')
			canvas(bind:this='{dom.minimap_field}')

</template><style>

	minimap_width = 4rem
	article
		grid-area comments
		height 100%
		contain strict
		display flex
		flex-flow column nowrap
	#comments
		flex 1
		padding 0 2rem 2rem 0
		overflow-x auto
		overflow-y scroll
		word-break break-word
		will-change transform //https://bugs.chromium.org/p/chromium/issues/detail?id=514303
		&::-webkit-scrollbar
			width 1 * minimap_width
			background transparent
		&::-webkit-scrollbar-thumb
			border-width 4px 0 2px 0
			border-style solid
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

</style><script>

	export post = {}

	import { onMount, afterUpdate } from 'svelte'
	import Comment from '/comp/Comment'
	
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
		max_depth = 8
		canvas_context = dom.minimap_field.getContext '2d'
		canvas_context.clearRect(0, 0, dom.minimap_field.width, dom.minimap_field.height)
		canvas_context.fillStyle = 'black'
		draw_minimap_symbols = (comment, current_depth) ->
			if not comment.classList.contains 'comment' then return
			if current_depth > max_depth then return
			canvas_context.fillRect(
				dom.minimap.scrollWidth / max_depth * (current_depth - 1),
				Math.trunc(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight),
				1,
				comment.scrollHeight / dom.comments.scrollHeight * dom.minimap.scrollHeight
			)
			for child in comment.children[1].children
				draw_minimap_symbols(child, current_depth + 1)
		for child in dom.comments.children
			draw_minimap_symbols(child, 1)

</script>