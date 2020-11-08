<template lang='pug'>
	+if('active')
		nav(style!='top: {y-40}px; left: {x-40}px')
			div#crossbar1
			div#crossbar2
</template>

<style>
	nav
		position absolute
		width 80px
		height 80px
		overflow hidden
	#crossbar1
	#crossbar2
		position absolute
		top 50%
		left 0
		width 80px
		height 2px
		border 1px solid
	#crossbar1
		transform rotate(45deg)
	#crossbar2
		transform rotate(-45deg)
</style>

<script>
	export active = false
	export x = 0
	export y = 0
	export dir = ''

	###
	document.onmousedown = (e) ->
		if e.buttons is 2
			x = e.x
			y = e.y
			dir = ''
			active = true
			comment = e.path.find((element) -> element.classList and element.classList.contains('comment'))
	document.onmouseup = (e) -> active = false
	document.onmousemove = (e) ->
		if active
			up = y - e.y
			right = e.x - x
			dir = ''
			if Math.abs(up) > 24 or Math.abs(right) > 24
				if Math.abs(up) > Math.abs(right)
					if up > 0
						dir = 'n'
					else
						dir = 's'
				else
					if right > 0
						dir = 'e'
					else
						dir = 'w'
	###

	document.keyboard_shortcuts.ShiftLeft =
		n: 'Show X-Menu'
		d: () => active = true
		u: () => active = false
</script>