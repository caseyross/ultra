<template>
+if('post.content')
	#post
		+if('post.content.type === "html"')
			+if('post.content.html.length')
				#self-text {@html post.content.html}
				+else
					#error-text NO TEXT
			+elseif('post.content.type === "image"')
				img(src='{post.content.url}')
			+elseif('post.content.type === "images"')
				Gallery(images='{post.content.images}')
			+elseif('post.content.type === "video"')
				MediaPlayer(audio_url='{post.content.audio_url}' video_url='{post.content.url}' video_preview_url='{post.content.preview_url}')
			+elseif('post.content.type === "post"')
				+await('post.content.POST then content_post')
					Comments(post='{content_post}')
			+elseif('post.content.type === "link"')
				iframe(src='{post.content.url}' sandbox='allow-scripts allow-same-origin')
			+else
				#error-text CANNOT PARSE POST
</template>

<style>
	#post
		height: 100%
	#content
		height: 100%
		overflow: auto
		display: flex
		flex-flow: column nowrap
		align-items: flex-end
	#image
		position: relative
		&:hover > .src-url
			opacity: 1 
	data
		position: absolute
		background: black
		color: white
	.numbering
		top: 0
		left: 0
	.scale
		top: 0
		right: 0
	.src-url
		bottom: 0
		left: 0
		text-decoration: none
		opacity: 0
	#self-text
		height: 100%
		padding: 16px
		overflow: auto
		font-size: 13px
		line-height: 1.5
		&::-webkit-scrollbar
			width: 4px
			background: transparent
		&::-webkit-scrollbar-thumb
			background: gray
	#error-text
		font-size: 64px
		font-weight: 900
		color: #eee
		transform: rotate(-45deg)
</style>

<script>
	import { feed } from './state.coffee'
	import Gallery from './Gallery.svelte'
	import MediaPlayer from './MediaPlayer.svelte'
	import Comments from './Comments.svelte'
	export post = {}
	dom =
		image: {}
	scale_percent = (image) ->
		if not image.naturalWidth and image.naturalHeight then return ''
		width_fraction = image.naturalWidth / window.innerWidth * 0.4
		height_fraction = image.naturalHeight / window.innerHeight - 80
		if width_fraction > 1 and height_fraction > 1
			scale_percent = Math.trunc(Math.min(1 / width_fraction, 1 / height_fraction) * 100) + '%'
		else if width_fraction > 1
			scale_percent = Math.trunc(1 / width_fraction * 100) + '%'
		else if height_fraction > 1
			scale_percent = Math.trunc(1 / height_fraction * 100) + '%'
		else
			scale_percent = ''
</script>