<template>

	article
		#comments(bind:this='{dom.comments}' on:mousedown='{teleportViaMinimap}')
			+each('comments.list as comment')
				Comment(comment='{comment}')
				+else
					#nocomments
						button#add-first-comment ADD THE FIRST COMMENT
		figure(bind:this='{dom.minimap}')
			canvas(bind:this='{dom.minimapField}')

</template><style>

	minimapWidth = 4rem
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
			width 1 * minimapWidth
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
		width minimapWidth
		position absolute
		top 0
		right 0
		pointer-events none

</style><script>

	export comments = {}

	import Comment from '/templates/Comment'
	import { onMount } from 'svelte'
	
	dom =
		comments: {}
		minimap: {}
		minimapField: {}
	teleportViaMinimap = (click) ->
		if dom.comments.clientWidth - click.layerX < 0
			dom.comments.scrollTop = click.layerY / dom.minimap.scrollHeight * dom.comments.scrollHeight - dom.minimap.scrollHeight / 2
	onMount () ->
		# <canvas> can't be sized properly in static CSS (only scaled)
		dom.minimapField.width = dom.minimap.clientWidth
		dom.minimapField.height = dom.minimap.clientHeight
		drawMinimap()
	resetScroll = () ->
		dom.comments.scrollTop = 0
	drawMinimap = () ->
		maxDepth = 8
		canvasContext = dom.minimapField.getContext '2d'
		canvasContext.clearRect(0, 0, dom.minimapField.width, dom.minimapField.height)
		canvasContext.fillStyle = 'black'
		drawMinimapSymbols = (comment, currentDepth) ->
			if not comment.classList.contains 'comment' then return
			if currentDepth > maxDepth then return
			canvasContext.fillRect(
				dom.minimap.scrollWidth / maxDepth * (currentDepth - 1),
				Math.trunc(comment.offsetTop / dom.comments.scrollHeight * dom.minimap.scrollHeight),
				1,
				comment.scrollHeight / dom.comments.scrollHeight * dom.minimap.scrollHeight
			)
			for child in comment.children[1].children
				drawMinimapSymbols(child, currentDepth + 1)
		for child in dom.comments.children
			drawMinimapSymbols(child, 1)

</script>