<template>
	#player(bind:this='{dom.player}')
		+if('audio_url || video_url')
			video(
				src='{video_url}'
				bind:duration='{v.duration}'
				bind:currentTime='{v.time}'
				bind:paused='{v.paused}'
			)
			audio(
				src='{audio_url}'
				bind:paused='{a.paused}'
			)
			nav(on:mousedown!='{() => play_pause()}')
				#scrubber-track
					#scrubber(style!='transform: scaleX({v.time / v.duration})')
			+else
				div CANNOT LOAD AUDIO/VIDEO
</template>

<style>
	#player
		overflow: hidden
		position: relative
	nav
		position: absolute
		top: 0
		left: 0
		width: 100%
		height: 100%
	#scrubber-track
		position: absolute
		bottom: 0
		left: 0
		height: 4px
		width: 100%
		background: #333
	#scrubber
		position: absolute
		height: 100%
		width: 100%
		background: white
		transform-origin: left center
</style>

<script>
	import { duration } from './time.coffee'
	export audio_url = ''
	export video_url = ''
	export video_preview_url = ''
	dom =
		player: {}
	a =
		paused: true
	v =
		duration: 0
		time: 0
		paused: true
	play_pause = () ->
		v.paused = not v.paused
		a.paused = not a.paused
	fullscreen = () ->
		if document.fullscreenElement
			document.exitFullscreen()
		else
			dom.player.requestFullscreen()
</script>