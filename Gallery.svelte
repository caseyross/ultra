<template>
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
			img(src='{images[i].url_640}')
			figcaption
				| {images[i].caption || ''}
				a(href='{images[i].caption_url}') {images[i].caption_url || ''}
			a(href='{images[i].url_full}' target='_blank' rel='noopener') View full size
</template>

<style>
	#thumbnails
		display: flex
		flex-flow: row wrap
	.thumbnail
		width: 80px
		height: 80px
		object-fit: cover
		border: 4px solid transparent
		opacity: 0.5
		&:hover
			opacity: 0.8
			border-color: gray
		&.selected
			opacity: 1
			border-color: black
</style>

<script>
	export images = []
	i = 0
</script>