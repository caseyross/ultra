<template lang='pug'>

	#gallery
		menu
			+if('images.length > 1')
				button
					kbd A
					| back
				+each('images as image, j')
					img.thumbnail(
						src='{image.url_640}'
						on:click!='{() => i = j}'
						class:selected!='{i == j}'
					)
				button
					kbd D
					| next
				+else
					button
						kbd E
						| enlarge
					button
						kbd F
						| fullscreen
					a(href='{images[i].url_full}' target='_blank' rel='noopener')
						kbd O
						| open original
		figure
			img(src='{images[i].url_640}')
			+if('images[i].caption')
				figcaption
					| {images[i].caption}
					+if('images[i].caption_url')
						a(href='{images[i].caption_url}')
							kbd L
							| {(new URL(images[i].caption_url)).hostname}

</template><style>

	menuHeight = 8rem
	captionHeight = 8rem
	#gallery
		height 100%
	menu
		position absolute
		height menuHeight
		display flex
		flex-flow row nowrap
		align-items center
		button
			padding 1rem
		img
			box-sizing content-box
			height 5rem
			width 5rem
			padding 0.5rem
			border-width 0.5rem 1px
			border-style solid
			border-color transparent
			object-fit scale-down
			&:hover
				opacity 0.8
			&.selected
				opacity 1
				border-color inherit
	figure
		height 100%
		img
			object-fit scale-down
	figcaption
		position absolute
		max-height captionHeight
		padding 2rem
		overflow auto
		text-align center
		background antiquewhite
		border 1px solid
		a
			padding 1rem

</style><script>

	export images = []
	
	i = 0

	document.keyboardShortcuts.KeyE =
		n: 'Media: Enlarge'
	document.keyboardShortcuts.KeyF =
		n: 'Media: Fullscreen'
	document.keyboardShortcuts.KeyO =
		n: 'Media: Open Original Source'
		d: () => window.open(images[i].url_full)
	document.keyboardShortcuts.KeyA =
		n: 'Gallery: Previous Image'
		d: () => if i > 0 then i -= 1
	document.keyboardShortcuts.KeyD =
		n: 'Gallery: Next Image'
		d: () => if i < images.length - 1 then i += 1
		
</script>