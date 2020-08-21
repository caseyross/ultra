<template>
#gallery
	+each('images as image')
		figure
			img(src='{image.url}')
			figcaption
				span {image.caption}
				a(href='{image.caption_url}') {image.caption_url || ''}
</template>

<style>
	#gallery
		height: 100%
		overflow: auto
		&::-webkit-scrollbar
			width: 4px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: gray
</style>

<script>
	export images = []
</script>