<template lang='pug'>
	#gallery
		#thumbnails
			+if('images.length > 1')
				+each('images as image, j')
					img.thumbnail(
						src='{image.url_640}'
						on:click!='{() => i = j}'
						class:selected!='{i == j}'
					)
		figure
			menu
				button
					kbd E
					| enlarge
				button
					kbd F
					| fullscreen
				button
					a(href='{images[i].url_full}' target='_blank' rel='noopener')
						kbd O
						| open original
			img(src='{images[i].url_640}')
			figcaption
				| {images[i].caption || ''}
				a(href='{images[i].caption_url}') {images[i].caption_url || ''}
</template>

<style>
	#gallery
		height 100%
		position relative
	figure
		flex 1
	img
		object-fit contain
	menu
		margin-bottom 8px
	button
		color gray
		& ~ &
			margin-left 24px
		a
			color inherit
			text-decoration none
	figcaption
		margin-top 8px
		font-style italic
		a
			margin-left: 8px
	#thumbnails
		flex 0 0 auto
		display flex
		flex-flow row wrap
	.thumbnail
		width 58px
		height 58px
		padding 1rem
		object-fit cover
		border 1px solid transparent
		opacity 0.5
		&:hover
			opacity 0.8
			border-color gray
		&.selected
			opacity 1
			border-color black
</style>

<script>
	export images = []
	
	i = 0
</script>