<template lang='pug'>

	menu(style!="{active ? 'transform: translate(' + position.x + 'px,' + position.y + 'px) rotate(45deg)' : ''}")
		button.large#w Reply
		button.large#a
		button.large#s Save
		button.large#d Hide
		button.small#q
		button.small#z
		button.small#e
		button.small#c

</template><style>

	menu
		position absolute
		width 40rem
		height 40rem
		top -20rem
		left -20rem
		display grid
		grid-template-rows 2fr 2fr 1fr 1fr 2fr 2fr
		grid-template-columns 2fr 2fr 1fr 1fr 2fr 2fr
		grid-template-areas:
			'. . e e . .' \
			'. w w d d .' \
			'q w w d d c' \
			'q a a s s c' \
			'. a a s s .' \
			'. . z z . .'
		transform rotate3d(0.5, 0, 0, 90deg)
	button
		transform rotate(-45deg)
	#w
		grid-area w
	#a
		grid-area a
	#s
		grid-area s
	#d
		grid-area d
	#q
		grid-area q
	#z
		grid-area z
	#e
		grid-area e
	#c
		grid-area c

</style><script>

	export active = false
	position =
		x: 0
		y: 0

	document.addEventListener 'mousedown',
		(e) ->
			if e.buttons is 2
				position =
					x: e.x
					y: e.y
				active = true
	document.addEventListener 'mouseup',
		(e) ->
			active = false

	document.keyboardShortcuts.ShiftLeft =
		n: 'Show X-Menu'
		d: () => active = true
		u: () => active = false
		
</script>