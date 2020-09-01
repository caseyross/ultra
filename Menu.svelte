<template>
+if('show_menu')
	#outer(style='top: {y - 96}px; left: {x - 96}px;')
		#option-n Reply
		#option-e Award
		#option-s Report
		#option-w Save
	#inner(style='top: {y - 24}px; left: {x - 24}px;') Upvote
</template>

<style>
	#outer
		position: absolute
		width: 192px
		height: 192px
		border-radius: 50%
		background: var(--tc-m)
		display: flex
		justify-content: center
		align-items: center
		font-size: 24px
		cursor: crosshair
	#inner
		position: absolute
		width: 48px
		height: 48px
		border-radius: 50%
		background: black
		display: flex
		justify-content: center
		align-items: center
	#option-n
	#option-e
	#option-s
	#option-w
		position: absolute
		font-size: 12px
		background: var(--tc-m)
	#option-n
		top: 32px
	#option-e
		left: 136px
	#option-s
		bottom: 32px
	#option-w
		right: 136px
</style>

<script>
	import { Key } from './input.coffee'
	export x = 0
	export y = 0
	export dir = ''
	export show_menu = false
	document.addEventListener('mousedown', (e) ->
		if e.buttons is 2
			x = e.x
			y = e.y
			dir = ''
			show_menu = true
			comment = e.path.find((element) -> element.classList and element.classList.contains('comment'))
	)
	document.addEventListener('mousemove', (e) ->
		if show_menu
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
	)
	document.addEventListener('mouseup', (e) ->
		show_menu = false
	)
	document.addEventListener('keydown', (e) ->
		switch e.code
			when Key.LShift
				show_menu = true
	)
	document.addEventListener('keyup', (e) ->
		switch e.code
			when Key.LShift
				show_menu = false
	)
</script>